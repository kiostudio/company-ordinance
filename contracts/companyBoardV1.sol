// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./erc20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";

contract CompanyBoard is AccessControlEnumerable {
    bytes32 public constant BOARD_MEMBER_ROLE = keccak256("BOARD_MEMBER_ROLE");
    bytes32 public constant COMPANY_MODERATOR_ROLE = keccak256("COMPANY_MODERATOR_ROLE");
    struct Share {
        address delegate;
        uint share;
    }
    mapping (address => Share) public sharesDist;
    address [] public shareHoldersList;
    bool private init = false;
    address private shareIssuerAddress;
    bytes32 public companyType = keccak256("PRIVATE");

    constructor(address[] memory _boardMembers, uint256[] memory shares){
        console.log("Contract Deployer : ",msg.sender);
        // _setupRole(keccak256("DEFAULT_ADMIN_ROLE"), msg.sender);
        _setBoardMembers(_boardMembers,shares);
        _setupRole(COMPANY_MODERATOR_ROLE, msg.sender);
    }
    function _setBoardMembers(address[] memory _boardMembers, uint256[] memory shares) internal{
        for(uint256 i = 0; i < _boardMembers.length; i++) {
            console.log("Add New Board Member : ",_boardMembers[i],shares[i]);
            // grantRole(BOARD_MEMBER_ROLE, _boardMembers[i]);
            _setupRole(BOARD_MEMBER_ROLE, _boardMembers[i]);
            shareHoldersList.push(_boardMembers[i]);
            sharesDist[_boardMembers[i]].share = shares[i];
        }
        // boardMembers = _boardMembers;
    }
    function setShareIssuer(address _shareIssuerAddress) external{
        require(hasRole(COMPANY_MODERATOR_ROLE, msg.sender), "Caller is not a Moderator");
        shareIssuerAddress = _shareIssuerAddress;
        renounceRole(COMPANY_MODERATOR_ROLE, msg.sender);
    }
    function initSharesIssue() external returns (uint) {
        // console.log('sharesIssuer Address :',shareIssuerAddress);
        require(init == false,"Init Share already issued.");
        require(shareIssuerAddress != 0x0000000000000000000000000000000000000000,"Share Issuer not yet already.");
        uint totalMembers = getRoleMemberCount(BOARD_MEMBER_ROLE);
        console.log('Number of Board Members :',totalMembers);
        console.log('sharesIssuer Address :',shareIssuerAddress);
        console.log(Address.isContract(shareIssuerAddress));
        for(uint256 i = 0; i < shareHoldersList.length; i++) {
            ERC20Mint shareInstance = ERC20Mint(shareIssuerAddress);
            console.log('This shareholders proportions : ',sharesDist[shareHoldersList[i]].share);
            shareInstance.mint(shareHoldersList[i], sharesDist[shareHoldersList[i]].share);
        }
        init = true;
        return totalMembers;
    }
    function getVotingWeight(address member, address sharesIssuer) external view returns(uint256){
        require(hasRole(BOARD_MEMBER_ROLE, msg.sender), "Caller is not a Board Memeber");
        console.log('Shares Belong to the Board Memeber : ',ERC20Mint(sharesIssuer).balanceOf(member));
        console.log('Total Sahres Issued : ',ERC20Mint(sharesIssuer).totalSupply());
        uint quotient = uint(ERC20Mint(sharesIssuer).balanceOf(member))*(10*10000)/uint(ERC20Mint(sharesIssuer).totalSupply());
        console.log('Member Weight : ',quotient);
        return quotient;
    }
    // Proposal
    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    function initProposal() external{
        require(hasRole(BOARD_MEMBER_ROLE, msg.sender), "Caller is not a Board Memeber");
    }
    // Vote
    // Result

    // Shares Dilution
    // Company Liquidation
    // IPO / ICO
    // Assets Related (Movement)
    // Others Proposal

    // struct Voter {
    //     uint weight; // weight is accumulated by delegation
    //     bool voted;  // if true, that person already voted
    //     address delegate; // person delegated to
    //     uint vote;   // index of the voted proposal
    // }

    // // This is a type for a single proposal.
    // struct Proposal {
    //     bytes32 name;   // short name (up to 32 bytes)
    //     uint voteCount; // number of accumulated votes
    // }

    // // address public chairperson;

    // // This declares a state variable that
    // // stores a `Voter` struct for each possible address.
    // mapping(address => Voter) public voters;

    // // A dynamically-sized array of `Proposal` structs.
    // Proposal[] public proposals;

    // // function getBoardMembers() public returns (address[] memory) {
    // //     return boardMembers;
    // // }

    // /// Create a new ballot to choose one of `proposalNames`.
    // // constructor(bytes32[] memory proposalNames) {
    // //     chairperson = msg.sender;
    // //     voters[chairperson].weight = 1;

    // //     // For each of the provided proposal names,
    // //     // create a new proposal object and add it
    // //     // to the end of the array.
    // //     for (uint i = 0; i < proposalNames.length; i++) {
    // //         // `Proposal({...})` creates a temporary
    // //         // Proposal object and `proposals.push(...)`
    // //         // appends it to the end of `proposals`.
    // //         proposals.push(Proposal({
    // //             name: proposalNames[i],
    // //             voteCount: 0
    // //         }));
    // //     }
    // // }

    // // function createProposal(address owner, bytes32[] memory proposalName) public{
    // //     require(hasRole(BOARD_MEMBER_ROLE, msg.sender), "Caller is not a Board Memeber");
    // // }

    // // Give `voter` the right to vote on this ballot.
    // // May only be called by `chairperson`.
    // function giveRightToVote(address voter) public {
    //     // If the first argument of `require` evaluates
    //     // to `false`, execution terminates and all
    //     // changes to the state and to Ether balances
    //     // are reverted.
    //     // This used to consume all gas in old EVM versions, but
    //     // not anymore.
    //     // It is often a good idea to use `require` to check if
    //     // functions are called correctly.
    //     // As a second argument, you can also provide an
    //     // explanation about what went wrong.
    //     // require(
    //     //     msg.sender == chairperson,
    //     //     "Only chairperson can give right to vote."
    //     // );
    //     require(
    //         !voters[voter].voted,
    //         "The voter already voted."
    //     );
    //     require(voters[voter].weight == 0);
    //     voters[voter].weight = 1;
    // }

    // /// Delegate your vote to the voter `to`.
    // function delegate(address to) public {
    //     // assigns reference
    //     Voter storage sender = voters[msg.sender];
    //     require(!sender.voted, "You already voted.");

    //     require(to != msg.sender, "Self-delegation is disallowed.");

    //     // Forward the delegation as long as
    //     // `to` also delegated.
    //     // In general, such loops are very dangerous,
    //     // because if they run too long, they might
    //     // need more gas than is available in a block.
    //     // In this case, the delegation will not be executed,
    //     // but in other situations, such loops might
    //     // cause a contract to get "stuck" completely.
    //     while (voters[to].delegate != address(0)) {
    //         to = voters[to].delegate;

    //         // We found a loop in the delegation, not allowed.
    //         require(to != msg.sender, "Found loop in delegation.");
    //     }

    //     // Since `sender` is a reference, this
    //     // modifies `voters[msg.sender].voted`
    //     sender.voted = true;
    //     sender.delegate = to;
    //     Voter storage delegate_ = voters[to];
    //     if (delegate_.voted) {
    //         // If the delegate already voted,
    //         // directly add to the number of votes
    //         proposals[delegate_.vote].voteCount += sender.weight;
    //     } else {
    //         // If the delegate did not vote yet,
    //         // add to her weight.
    //         delegate_.weight += sender.weight;
    //     }
    // }

    // /// Give your vote (including votes delegated to you)
    // /// to proposal `proposals[proposal].name`.
    // function vote(uint proposal) public {
    //     Voter storage sender = voters[msg.sender];
    //     require(sender.weight != 0, "Has no right to vote");
    //     require(!sender.voted, "Already voted.");
    //     sender.voted = true;
    //     sender.vote = proposal;

    //     // If `proposal` is out of the range of the array,
    //     // this will throw automatically and revert all
    //     // changes.
    //     proposals[proposal].voteCount += sender.weight;
    // }

    // /// @dev Computes the winning proposal taking all
    // /// previous votes into account.
    // function winningProposal() public view
    //         returns (uint winningProposal_)
    // {
    //     uint winningVoteCount = 0;
    //     for (uint p = 0; p < proposals.length; p++) {
    //         if (proposals[p].voteCount > winningVoteCount) {
    //             winningVoteCount = proposals[p].voteCount;
    //             winningProposal_ = p;
    //         }
    //     }
    // }

    // // Calls winningProposal() function to get the index
    // // of the winner contained in the proposals array and then
    // // returns the name of the winner
    // function winnerName() public view
    //         returns (bytes32 winnerName_)
    // {
    //     winnerName_ = proposals[winningProposal()].name;
    // }
}