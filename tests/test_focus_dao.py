from eth_account import Account
from brownie import accounts
from scripts.helpful_scripts import get_account
from scripts.deploy_focus_dao import deploy
import pytest



def test_create_proposal():
    bob = get_account()
   
    dao_contract = deploy()

    description = "Mint more Iconic tokens"

    eligible_address = [
        "0xA66F90C0B7be6955D6c8f9B16dfD0A56171e038e",
        "0xC68b4573794ee051C80851233310aaC9D726934d",
        "0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B"
    ]

    tx =  dao_contract.createProposal(
        description,
        eligible_address,
        {"from": bob}
    )

    print(tx.events)

    