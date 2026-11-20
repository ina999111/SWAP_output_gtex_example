
from cobra.io import (load_json_model)
from cobra import Model
import json


model_inhouse_v9 = load_json_model(r"data/raw/model_inhouse_v9.json")


def is_transport(model: Model,
                 rxn_id: str
) -> bool:
    """
    Looks at the reaction id in the specified model and evaluates if it is a transport reaction
    defined as having at least 1 metabolite be the same in substrate and product, but with different compartment
    :param model: a cobra model
    :param rxn_id: reaction id as in the model
    :return: true or false
    """

    rxn = model.reactions.get_by_id(rxn_id)
    list_substrates_names = [met.name for met in rxn.reactants]
    list_products_names = [met.name for met in rxn.products]

    list_substrates_compartment = [met.id[-3:] for met in rxn.reactants]
    list_products_compartment = [met.id[-3:] for met in rxn.products]

    # if a substrate is also a product, then look at compartment
    common_met = set(list_substrates_names).intersection(set(list_products_names))

    if bool(common_met) is True:  # if set not empty
        for met_name in common_met:
            substrate_compartment = list_substrates_compartment[list_substrates_names.index(met_name)]
            product_compartment = list_products_compartment[list_products_names.index(met_name)]

            if substrate_compartment != product_compartment:
                return True
            else:
                return False
    else:
        return False


# transport reactions
list_transport_rxns_model_v9 = []
for reaction in model_inhouse_v9.reactions:
    if is_transport(model_inhouse_v9, reaction.id):
        list_transport_rxns_model_v9.append(reaction.id)

# exchange reactions
list_exchange_reactions_model_v9 = []
for reaction in model_inhouse_v9.reactions:
    if reaction.boundary:
        list_exchange_reactions_model_v9.append(reaction.id)

# GPRless reactions
list_GPRless_model_v9 = []
for reaction in model_inhouse_v9.reactions:
    if reaction.gene_reaction_rule == '':
        list_GPRless_model_v9.append(reaction.id)

# verification
model_inhouse_v9.reactions.get_by_id(list_transport_rxns_model_v9[1]).reaction # should be a transport reaction
model_inhouse_v9.reactions.get_by_id(list_exchange_reactions_model_v9[1]).reaction # should be an exchange reaction
model_inhouse_v9.reactions.get_by_id(list_GPRless_model_v9[1]).gene_reaction_rule # should be empty

# save lists
with open (r'data/raw/list_transport_rxns_model_v9.json', 'w') as file:
    json.dump(list_transport_rxns_model_v9, file)

with open (r'data/raw/list_exchange_reactions_model_v9.json', 'w') as file:
    json.dump(list_exchange_reactions_model_v9, file)

with open (r'data/raw/list_GPRless_model_v9.json', 'w') as file:
    json.dump(list_GPRless_model_v9, file)
