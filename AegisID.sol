// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AegisID — privacy-conscious identity status demo
/// @notice Stores only a random commitment and status, never identity documents.
contract AegisID {
    address public owner;

    struct Identity {
        bytes32 commitment;
        bool registered;
        bool verified;
    }

    mapping(address => Identity) private identities;
    mapping(address => bool) public issuers;

    event IdentityRegistered(address indexed user, bytes32 commitment);
    event IdentityVerified(address indexed user, address indexed issuer);
    event IssuerUpdated(address indexed issuer, bool enabled);

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }

    modifier onlyIssuer() {
        require(issuers[msg.sender], "Authorized issuer only");
        _;
    }

    constructor() {
        owner = msg.sender;
        issuers[msg.sender] = true;
        emit IssuerUpdated(msg.sender, true);
    }

    function setIssuer(address issuer, bool enabled) external onlyOwner {
        require(issuer != address(0), "Invalid address");
        issuers[issuer] = enabled;
        emit IssuerUpdated(issuer, enabled);
    }

    function registerIdentity(bytes32 commitment) external {
        require(commitment != bytes32(0), "Empty commitment");
        require(!identities[msg.sender].registered, "Already registered");

        identities[msg.sender] = Identity({
            commitment: commitment,
            registered: true,
            verified: false
        });

        emit IdentityRegistered(msg.sender, commitment);
    }

    function verifyIdentity(address user) external onlyIssuer {
        require(identities[user].registered, "Identity not registered");
        require(!identities[user].verified, "Already verified");

        identities[user].verified = true;
        emit IdentityVerified(user, msg.sender);
    }

    function checkIdentity(address user)
        external
        view
        returns (bool registered, bool verified, bytes32 commitment)
    {
        Identity memory identity = identities[user];
        return (identity.registered, identity.verified, identity.commitment);
    }
}
