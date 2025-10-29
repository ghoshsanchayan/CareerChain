
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Job Application & Response Tracker (immutable app + append-only responses)
/// @author
/// @notice Applicants store an IPFS CID (or other off-chain pointer). Owner/employer can append responses.
contract JobApplicationTracker {
    address public owner;
    uint public applicationCount;

    /// Responses are append-only; status helps track workflow.
    enum ResponseStatus { None, Received, Reviewed, Interview, Rejected, Accepted }

    struct Application {
        uint id;
        address applicant;
        string ipfsCid;    // pointer to resume / details stored off-chain (e.g., IPFS CID)
        string position;   // role applied for
        uint timestamp;
    }

    struct Response {
        address responder;
        string message;    // short note (e.g., "We invited you to interview")
        ResponseStatus status;
        uint timestamp;
    }

    // storage
    mapping(uint => Application) public applications;    // appId => Application
    mapping(uint => Response[]) private responses;        // appId => list of Responses
    mapping(address => bool) public isResponder;         // addresses allowed to respond (owner can add)

    // events
    event ApplicationSubmitted(uint indexed id, address indexed applicant, string ipfsCid, string position);
    event ResponseAdded(uint indexed appId, uint indexed responseIndex, address indexed responder, ResponseStatus status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyAuthorizedResponder() {
        require(msg.sender == owner || isResponder[msg.sender], "Not authorized to respond");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

   /// @notice Submit a job application. Applicant keeps the original data off-chain (IPFS/CID).
/// @param ipfsCid pointer to resume/data stored off-chain
/// @param position job position applied for
function submitApplication(string calldata ipfsCid, string calldata position) external {
    require(bytes(ipfsCid).length > 0, "ipfsCid required");
    require(bytes(position).length > 0, "position required");

    applicationCount += 1;
    applications[applicationCount] = Application({
        id: applicationCount,
        applicant: msg.sender,
        ipfsCid: ipfsCid,
        position: position,
        timestamp: block.timestamp
    });

    emit ApplicationSubmitted(applicationCount, msg.sender, ipfsCid, position);
}

    /// @notice Add an immutable (append-only) response to an application
    /// @param appId application id to respond to
    /// @param message short message describing the response
    /// @param status status enum value
    function addResponse(uint appId, string calldata message, ResponseStatus status) external onlyAuthorizedResponder {
        require(appId > 0 && appId <= applicationCount, "invalid appId");

        responses[appId].push(Response({
            responder: msg.sender,
            message: message,
            status: status,
            timestamp: block.timestamp
        }));

        uint idx = responses[appId].length - 1;
        emit ResponseAdded(appId, idx, msg.sender, status);
    }

    /// @notice Get number of responses for an application
    function getResponseCount(uint appId) external view returns (uint) {
        return responses[appId].length;
    }

    /// @notice Read a single response by index (0-based)
    function getResponse(uint appId, uint index) external view returns (
        address responder,
        string memory message,
        ResponseStatus status,
        uint timestamp
    ) {
        require(appId > 0 && appId <= applicationCount, "invalid appId");
        require(index < responses[appId].length, "index out of bounds");
        Response storage r = responses[appId][index];
        return (r.responder, r.message, r.status, r.timestamp);
    }

    /// @notice Owner can grant/revoke responder rights (for HR team addresses)
    function setResponder(address responderAddr, bool allowed) external onlyOwner {
        require(responderAddr != address(0), "zero address");
        isResponder[responderAddr] = allowed;
    }

    /// @notice Transfer contract ownership (employer)
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero address");
        owner = newOwner;
    }
}
