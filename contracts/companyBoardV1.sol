// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./sharesIssuerV1.sol";
import "./sharesIssuerFactoryCloneV1.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";

contract CompanyBoardV1 is AccessControlEnumerable, Initializable {
    /**
     * @dev Grants `BOARD_MEMBER_ROLE`, `COMPANY_MODERATOR_ROLE` to the
     * account that deploys the contract.
     *
     */
    bytes32 public constant BOARD_MEMBER_ROLE = keccak256("BOARD_MEMBER_ROLE");
    bytes32 public constant COMPANY_MODERATOR_ROLE = keccak256("COMPANY_MODERATOR_ROLE");
    address public sharesIssuerAddress;
    address public companySecrectaryAddress;
    uint public constant publicCompany = 0;
    uint public constant privateCompany = 1;
    uint public companyType;

    struct Voter {
        uint weight; // weight is accumulated by delegation
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }
    struct Option {
        uint count;
    }
    struct Proposal {
        uint id;
        uint voteCount;
        uint voteOptions;
        mapping(uint => Option) options;
        uint256 voteEnd;
        uint passRate;
        uint actionIndex;
        uint timelock;
        address secrectaryAddress;
        address [] voteAddresses;
        mapping(address => Voter) voters;
    }
    uint numProposals;
    // Proposal [] private Proposals;
    mapping (uint => Proposal) Proposals;

    function initialize(address[] memory boardMembers, uint256[] memory shares, string memory name, string memory symbol, address factoryAddress, address moderator) public initializer {
        console.log("Contract Deployer : ",msg.sender);
        // _setupRole(keccak256("DEFAULT_ADMIN_ROLE"), msg.sender);
        companyType = privateCompany;
        _setBoardMembers(boardMembers);
        _setupRole(COMPANY_MODERATOR_ROLE, moderator);
        _createSharesIssuer(name,symbol,factoryAddress,boardMembers,shares);
    }
    function _setBoardMembers(address[] memory boardMembers) internal{
        for(uint256 i = 0; i < boardMembers.length; i++) {
            console.log("Add New Board Member Role : ",boardMembers[i]);
            // grantRole(BOARD_MEMBER_ROLE, boardMembers[i]);
            _setupRole(BOARD_MEMBER_ROLE, boardMembers[i]);
            // shareHoldersList.push(boardMembers[i]);
            // sharesDist[boardMembers[i]].share = shares[i];
        }
        // boardMembers = boardMembers;
    }
    function _createSharesIssuer(string memory name, string memory symbol, address factoryAddress, address[] memory boardMembers, uint256[] memory shares) internal{
        console.log("Create Shares Issuer : " ,name, symbol, factoryAddress);
        console.log("This Contract Address : ",address(this));
        SharesIssuerFactoryCloneV1 shareIssuerFactoryInstance = SharesIssuerFactoryCloneV1(factoryAddress);
        address _sharesIssuerAddress = shareIssuerFactoryInstance.createShareIssuer(name, symbol, address(this));
        console.log("Shares Issuer Address",_sharesIssuerAddress);
        sharesIssuerAddress = _sharesIssuerAddress;
        for(uint256 i = 0; i < boardMembers.length; i++) {
            console.log("Issue Shares : ",boardMembers[i],shares[i]);
            SharesIssuerV1 sharesInstance = SharesIssuerV1(_sharesIssuerAddress);
            // console.log('This shareholders proportions : ',sharesDist[shareHoldersList[i]].share);
            sharesInstance.mint(boardMembers[i], shares[i]);
        }
    }
    // function getVotingWeight(address member, address sharesIssuer) external view returns(uint256){
    //     require(hasRole(BOARD_MEMBER_ROLE, msg.sender), "Caller is not a Board Memeber");
    //     console.log('Shares Belong to the Board Memeber : ',ERC20Mint(sharesIssuer).balanceOf(member));
    //     console.log('Total Sahres Issued : ',ERC20Mint(sharesIssuer).totalSupply());
    //     uint quotient = uint(ERC20Mint(sharesIssuer).balanceOf(member))*(10*10000)/uint(ERC20Mint(sharesIssuer).totalSupply());
    //     console.log('Member Weight : ',quotient);
    //     return quotient;
    // }
    // Governance
    // Proposal - For each proposal register as a NFT
        // - Content : Tile / Description / Attachment / Vote Options (metadata)
        // - Passing Rate
        // - Voting Time : Limit + Instant Pass
        // - Blind Voting
        // - Action
        // - Execution Time
        // - Yes / No Option
    function initProposal(uint proposalId, address secrectaryAddress, uint voteOptions, uint voteTime, uint passRate, uint actionIndex, uint timelock) external{
        require(hasRole(BOARD_MEMBER_ROLE, msg.sender), "Caller is not a Board Memeber");
        Proposal storage proposal = Proposals[numProposals++];
        proposal.id = proposalId;
        proposal.voteCount = 0;
        proposal.voteOptions = voteOptions;
        proposal.voteEnd = block.timestamp + voteTime * 1 days;
        proposal.passRate = passRate;
        proposal.actionIndex = actionIndex;
        proposal.timelock = timelock;
        proposal.secrectaryAddress = secrectaryAddress;
        for(uint256 i = 0; i < voteOptions; i++) {
            proposal.options[i] = Option({
                count : 0
            });
        }
    }

    function vote(uint proposalId, address secrectaryAddress, uint voteIndex) external{
        require(hasRole(BOARD_MEMBER_ROLE, msg.sender), "Caller is not a Board Memeber");
        SharesIssuerV1 sharesInstance = SharesIssuerV1(sharesIssuerAddress);
        for(uint256 i = 0; i < numProposals; i++) {
            if(Proposals[i].id == proposalId && Proposals[i].secrectaryAddress == secrectaryAddress){
                require(voteIndex <= Proposals[i].voteOptions, "Vote option is not valid");
                require(Proposals[i].voteEnd > block.timestamp, "Ballot is already ended");
                uint voterWeight = uint(sharesInstance.balanceOf(msg.sender));
                Proposals[i].voteCount = Proposals[i].voteCount + voterWeight;
                bool voteAlready = false;
                for(uint256 j = 0; j < Proposals[i].voteAddresses.length; j++) {
                    if(Proposals[i].voteAddresses[j] == msg.sender) voteAlready = true;
                }
                require(voteAlready == false, "Vote already");
                Proposals[i].voteAddresses.push(msg.sender);
                Voter storage voter = Proposals[i].voters[msg.sender]; 
                voter.vote = voteIndex;
                voter.delegate = msg.sender;
                voter.weight = voterWeight;               
                Proposals[i].voters[msg.sender] = Voter({
                    vote: voteIndex,
                    delegate: msg.sender,
                    weight: voterWeight
                });
                Proposals[i].options[voteIndex].count = Proposals[i].options[voteIndex].count + voterWeight;
                // Check whether the updated vote result fulfill the passing rate
                if(Proposals[i].voteCount >= sharesInstance.totalSupply() * Proposals[i].passRate / 100){
                    console.log('Pass the passing rate');
                    // Vote Count : Find Winning Options
                    uint _winResult = 0;
                    uint winningVoteCount = 0;
                    for(uint256 h = 0; h < Proposals[i].voteOptions; h++) {
                        console.log("Option Index : ",h);
                        console.log("Vote Count : ",Proposals[i].options[h].count);
                        if (Proposals[i].options[h].count > _winResult) {
                            winningVoteCount = Proposals[i].options[h].count;
                            _winResult = h;
                        }
                    }
                    console.log('Winning Result Index : ',_winResult);
                    if(_winResult == 0){
                        console.log('Winning to Change the Company Type');
                        // Execute that Voting Action
                        if(Proposals[i].actionIndex == 1){
                            // bytes32 public companyType = keccak256("PRIVATE");
                            if(companyType == publicCompany){
                                companyType = privateCompany;
                            } else {
                                companyType = publicCompany;
                            }
                        }
                    }
                } 
                // else {
                //     console.log('Not Yet pass the passing rate');
                // }
            }
        }
    }

    // function endProposal(uint proposalId, address secrectaryAddress) external{
    //     require(hasRole(COMPANY_MODERATOR_ROLE, msg.sender), "Caller is not a Board Moderator");
    //     for(uint256 i = 0; i < numProposals; i++) {
    //         if(Proposals[i].id == proposalId && Proposals[i].secrectaryAddress == secrectaryAddress){
    //             console.log('Now : ', block.timestamp);
    //             console.log('Vote End : ', Proposals[i].voteEnd);
    //             require(Proposals[i].voteEnd >= block.timestamp,"Ballot is not yet end");
    //             Proposals[i].status = 1;
    //         }
    //     }
    // }

    function proposalResult(uint proposalId, address secrectaryAddress) view external returns(uint voteCount, bool voteIsEnd, bool voteTimeEnd, bool voteHasResult, uint winResult){
        require(hasRole(BOARD_MEMBER_ROLE, msg.sender), "Caller is not a Board Memeber");
        SharesIssuerV1 sharesInstance = SharesIssuerV1(sharesIssuerAddress);
        for(uint256 i = 0; i < numProposals; i++) {
            if(Proposals[i].id == proposalId && Proposals[i].secrectaryAddress == secrectaryAddress){
                bool _voteTimeEnd = block.timestamp >= Proposals[i].voteEnd;
                bool _voteHasResult = Proposals[i].voteCount >= sharesInstance.totalSupply() * Proposals[i].passRate / 100;
                bool _voteIsEnd = _voteTimeEnd || _voteHasResult;
                uint _winResult = 0;
                uint winningVoteCount = 0;
                for(uint256 j = 0; j < Proposals[i].voteOptions; j++) {
                    console.log("Option Index : ",j);
                    console.log("Vote Count : ",Proposals[i].options[j].count);
                    if (Proposals[i].options[j].count > _winResult) {
                        winningVoteCount = Proposals[i].options[j].count;
                        _winResult = j;
                    }
                }
                console.log('Winning Result Index : ',_winResult);
                return(Proposals[i].voteCount,_voteIsEnd,_voteTimeEnd,_voteHasResult,_winResult);
            }
        }
    }

    // Vote : for a specific proposal : proposalId
        // Checking : 
        // - Board Member or Delegator or Not 
        // - Porposal Status
        // - Vote already or not
        // - Ballot end or not
        // Cast Voting / Emit
    
    // Ballot Result Declaration by Moderator

    // Voting Power Delegation

    // Execution
        // Memorandum ONLY - 0
        // Change Company Type - 1
        // Change Company Secrectary
        // Shares Dilution
        // Update BR Metadata
        // Company Liquidation
        // IPO / ICO / PO
        // Assets Related (Movement)
}