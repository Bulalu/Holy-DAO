from brownie import accounts, TestNFT, chain
from scripts.helpful_scripts import get_account
from scripts.deploy_focus_dao import deploy
import pytest
import brownie


description = "Hire more Solidity devs"
eligible_address = [
        "0xA66F90C0B7be6955D6c8f9B16dfD0A56171e038e",
        "0xC68b4573794ee051C80851233310aaC9D726934d",
        "0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B"
    ]

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


def nft():
    account = accounts[0]
    
    if len(TestNFT) > 0:
        return TestNFT[-1]
    else:
        contract = TestNFT.deploy({"from": account})
        return contract



def test_set_nft():
    account = accounts[0]

    dao = deploy()
    nft_contract = nft()
    tx = dao.setNFTContract(nft_contract, {"from": account})

    assert "updateNFTContract" in tx.events



def test_create_proposal():
    account = accounts[0]
    bob = accounts[1]

    nft_contract = nft()
    dao_contract = deploy()
    
    dao_contract.setNFTContract(nft_contract, {"from": account})

    with brownie.reverts("Only NFT holders can put forth Proposals"):
        dao_contract.createProposal(description, eligible_address, {"from": account})
    
    nft_contract.mint({"from": account})

    tx =  dao_contract.createProposal(
        description,
        eligible_address,
        {"from": account}
    )

    id = tx.events["proposalCreated"]["id"]

    assert "proposalCreated" in tx.events
    assert  dao_contract.proposal(id)["description"] == description
    assert  dao_contract.proposal(id)["exists"] == True

    return dao_contract
    

def test_vote():
    account = accounts[0]
    meg = accounts[1]
    quagmire = accounts[2]
    stu = accounts[3]

    nft_contract = nft()
    dao_contract = deploy()
    

    dao_contract.setNFTContract(nft_contract, {"from": account})
    nft_contract.mint({"from": account})
    dao_contract.createProposal(description, [account.address, quagmire.address, stu.address], {"from": account})
    
    with brownie.reverts("This Proposal does not exist"):
        dao_contract.voteOnProposal(2, True, {"from": account})

    with brownie.reverts("You can not vote on this Proposal"):
        dao_contract.voteOnProposal(1, True, {"from": meg})

    dao_contract.voteOnProposal(1, True, {"from": account})
    dao_contract.voteOnProposal(1, False, {"from": quagmire})
   

    assert dao_contract.proposal(1)["votesFor"] == 1
    assert dao_contract.proposal(1)["votesAgainst"] == 1

    with brownie.reverts("You have already voted on this Proposal"):
        dao_contract.voteOnProposal(1, True, {"from": quagmire})

    chain.mine(101)

    with brownie.reverts("The deadline has passed for this Proposal"):
        dao_contract.voteOnProposal(1, False, {"from": stu})


def test_count_votes():
    account = accounts[0]
    meg = accounts[1]
    quagmire = accounts[2]
    stu = accounts[3]

    nft_contract = nft()
    dao_contract = deploy()
    
    dao_contract.setNFTContract(nft_contract, {"from": account})
    nft_contract.mint({"from": account})
    tx = dao_contract.createProposal(description, [account.address, quagmire.address, stu.address, meg.address], {"from": account})
    

    #voting
    dao_contract.voteOnProposal(1, True, {"from": quagmire})
    dao_contract.voteOnProposal(1, False, {"from": stu})
    dao_contract.voteOnProposal(1, True, {"from": account})
    dao_contract.voteOnProposal(1, False, {"from": meg})

    with brownie.reverts("Ownable: caller is not the owner"):
        dao_contract.countVotes(1, {"from": meg})

    with brownie.reverts("This Proposal does not exist"):
        dao_contract.countVotes(2, {"from": account})

    with brownie.reverts("Voting has not concluded"):
        dao_contract.countVotes(1, {"from": account})

    chain.mine(101)

    dao_contract.countVotes(1, {"from": account})

    assert dao_contract.proposal(1)["passed"] == False

    with brownie.reverts("Count already conducted"):
        dao_contract.countVotes(1, {"from": account})








#0x705f8B395361218056B20eE5C36853AB84b8bbFF