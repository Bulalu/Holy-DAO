import React, { useEffect, useState } from "react";
import "./pages.css";
import { TabList, Tab, Widget, Tag, Table, Form, LinkTo} from "web3uikit";
import { Link } from "react-router-dom";
import { useMoralis, useMoralisWeb3Api, useWeb3ExecuteFunction } from "react-moralis";

const Home = () => {
  const [passRate, setPassRate] = useState(0);
  const [totalP, setTotalP] = useState(0);
  const [counted, setCounted] = useState(0);
  const [voters, setVoters] = useState(0);
  const { Moralis, isInitialized } = useMoralis();
  const [proposals, setProposals] = useState();
  const Web3Api = useMoralisWeb3Api();
  const [sub, setSub] = useState();
  const contractProcessor = useWeb3ExecuteFunction();


  async function createProposal(newProposal) {
    let options = {
      contractAddress: "0x8316B2Bd5876AC2816a1Aa851e18cF8D1de47C24",
      functionName: "createProposal",
      abi: [
        {
          "inputs": [
            {
              "internalType": "string",
              "name": "_description",
              "type": "string"
            },
            {
              "internalType": "address[]",
              "name": "_canVote",
              "type": "address[]"
            }
          ],
          "name": "createProposal",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
      ],
      params: {
        _description: newProposal,
        _canVote: voters,
      },
    };


    await contractProcessor.fetch({
      params: options,
      onSuccess: () => {
        console.log("Proposal Succesful");
        setSub(false);
      },
      onError: (status) => {
        console.log(status.error.message);
        alert(status.error.message);
        setSub(false);
      },
    });


  }


  async function getStatus(proposalId) {
    const ProposalCounts = Moralis.Object.extend("ProposalCounts");
    const query = new Moralis.Query(ProposalCounts);
    query.equalTo("uid", proposalId);
    const result = await query.first();
    if (result !== undefined) {
      if (result.attributes.passed) {
        return { color: "green", text: "Passed" };
      } else {
        return { color: "red", text: "Rejected" };
      }
    } else {
      return { color: "blue", text: "Ongoing" };
    }
  }

  useEffect(() => {
    if (isInitialized) {

      async function getProposals() {
        const Proposals = Moralis.Object.extend("Proposals");
        const query = new Moralis.Query(Proposals);
        query.descending("uid_decimal");
        const results = await query.find();
        const table = await Promise.all(
          results.map(async (e) => [
            e.attributes.uid,
            e.attributes.description,
            <Link to="/proposal" state={{
              description: e.attributes.description,
              color: (await getStatus(e.attributes.uid)).color,
              text: (await getStatus(e.attributes.uid)).text,
              id: e.attributes.uid,
              proposer: e.attributes.proposer
              
              }}>
              <Tag
                color={(await getStatus(e.attributes.uid)).color}
                text={(await getStatus(e.attributes.uid)).text}
              />
            </Link>,
          ])
        );
        setProposals(table);
        setTotalP(results.length);
        
      }


      async function getPassRate() {
        const ProposalCounts = Moralis.Object.extend("ProposalCounts");
        const query = new Moralis.Query(ProposalCounts);
        const results = await query.find();
        let votesUp = 0;

        results.forEach((e) => {
          if (e.attributes.passed) {
            votesUp++;
          }
        });

        setCounted(results.length);
        setPassRate((votesUp / results.length) * 100);
      }


      const fetchNFTOwners = async () => {
        const options = {
          address: "0x705f8B395361218056B20eE5C36853AB84b8bbFF",
          chain: "rinkeby",
        };
        const NFTOwners = await Web3Api.token.getNFTOwners(options);
        const addresses = NFTOwners.result.map((e) => e.owner_of);
        // removes duplicates from array list
        // create a PR on this
        const uniqueAddresses = [...new Set(addresses)]
        setVoters(uniqueAddresses);
      };


      fetchNFTOwners();
      getProposals();
      getPassRate();
      
    }
  }, [isInitialized]);


  return (
    <>
      <div className="content">
        <TabList defaultActiveKey={1} tabStyle="bulbUnion">
          <Tab tabKey={1} tabName="DAO">
            {proposals && (
            <div className="tabContent">
              Governance Overview
              <div className="widgets">
                <Widget
                  info={totalP}
                  title="Proposals Created"
                  style={{ width: "200%" }}
                >
                  <div className="extraWidgetInfo">
                    <div className="extraTitle">Pass Rate</div>
                    <div className="progress">
                      <div
                        className="progressPercentage"
                        style={{ width: `${passRate}%` }}
                      ></div>
                    </div>
                  </div>
                </Widget>
                <Widget info={voters.length} title="Eligible Voters" />
                <Widget info={totalP-counted} title="Ongoing Proposals" />
              </div>
              Recent Proposals
              <div style={{ marginTop: "30px" }}>
                <Table
                  columnsConfig="10% 70% 20%"
                  data={proposals}
                  header={[
                    <span>ID</span>,
                    <span>Description</span>,
                    <span>Status</span>,
                  ]}
                  pageSize={5}
                />
              </div>

              <Form
                  buttonConfig={{
                    isLoading: sub,
                    loadingText: "Submitting Proposal",
                    text: "Submit",
                    theme: "secondary",
                  }}
                  data={[
                    {
                      inputWidth: "100%",
                      name: "New Proposal",
                      type: "textarea",
                      validation: {
                        required: true,
                      },
                      value: "",
                    },
                  ]}
                  onSubmit={(e) => {
                    setSub(true);
                    createProposal(e.data[0].inputResult);
                  }}
                  title="Create a New Proposal"
                />


            </div>
            )}
          </Tab>
          <Tab tabKey={2} tabName="NFT">
            
           
 
             <div className="tabContent">
              Go mint yourself an NFT
              <div className="widgets">
                {/* <Widget
                  info={}
                  
                >
                  
                </Widget> */}
                <LinkTo
                    address="https://iconics-nft.vercel.app/"
                    iconLayout="trailing"
                    text="Mint NFT"
                    type="external" />
                
              </div>
              </div>


            
            
          </Tab>
        </TabList>
      </div>
      <div className="voting"></div>
    </>
  );
};

export default Home;
