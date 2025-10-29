# JobApplicationTracker

**Immutable Job Application & Append‑Only Response Tracker**

---

![Uploading Screenshot 2025-10-29 at 2.08.54 PM.png…]()

## Project Description

JobApplicationTracker is a beginner-friendly Solidity smart contract that stores job applications immutably and records employer responses in an append‑only history. Applications point to off‑chain applicant data (for example an IPFS CID), while responses (status updates, interview invites, rejections, etc.) are appended by authorized responders and cannot be modified or removed.

This repository is ideal for anyone learning Solidity and building decentralised hiring tools, audit‑friendly recruitment flows, or tamper‑evident application logs.

---

## Deployed Smart Contract Link

You can inspect the deployed contract here:

[https://repo.sourcify.dev/11142220/0x18A4Ea808735A97dC12F279BA1Ffc85EE69afAD1](https://repo.sourcify.dev/11142220/0x18A4Ea808735A97dC12F279BA1Ffc85EE69afAD1)

---

## What it does

* Lets applicants submit a short pointer to their resume or application data (e.g., an IPFS CID) along with the position they apply for.
* Keeps that application record immutable once submitted.
* Allows the contract owner and addresses granted permission to append responses to any application.
* Keeps an append‑only, tamper‑evident timeline of responses for each application (no edits or deletions allowed).
* Emits events for each submission and response to make indexing and building front‑ends easy.

---

## Features

* **Immutable applications:** Once submitted, application records are not changeable via the contract.
* **Append‑only responses:** Responses are pushed into an array for each application — they cannot be edited or removed through the contract API.
* **Access control for responders:** The contract owner can add or remove responder addresses (HR team wallets).
* **Event-driven:** `ApplicationSubmitted` and `ResponseAdded` events are emitted for easy off‑chain indexing.
* **Gas‑efficient design:** Only store short strings (CID, short messages) on‑chain to reduce costs.
* **Beginner-friendly:** Clear, commented Solidity (Solidity ^0.8.19) and a simple API for dApp integration.

---

## Contract API (important functions)

* `submitApplication(string ipfsCid, string position)` — Called by applicants to submit their application data pointer.
* `addResponse(uint appId, string message, ResponseStatus status)` — Called by owner or authorized responders to append a response to application `appId`.
* `getResponseCount(uint appId)` — View how many responses an application has.
* `getResponse(uint appId, uint index)` — Read a single response by index (0‑based).
* `setResponder(address responderAddr, bool allowed)` — Owner function to grant/revoke responder rights.
* `transferOwnership(address newOwner)` — Transfer contract owner rights.

**Enum:** `ResponseStatus { None, Received, Reviewed, Interview, Rejected, Accepted }`

---

## Example usage (ethers.js)

Below are tiny snippets showing how a front‑end or script might interact with the contract. Replace `CONTRACT_ADDRESS` and `ABI` with your contract address and ABI, and connect a provider/signer.

```javascript
// submit application (applicant)
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
await contract.submitApplication("ipfs://Qm...", "Frontend Engineer");

// owner / responder adds a response
await contract.addResponse(1, "Invite to interview: check email", 3); // 3 => Interview

// read responses
const count = await contract.getResponseCount(1);
for (let i = 0; i < count; i++) {
  const r = await contract.getResponse(1, i);
  console.log(r);
}
```

---

## Events (for indexing)

* `ApplicationSubmitted(uint indexed id, address indexed applicant, string ipfsCid, string position)` — emitted on `submitApplication`.
* `ResponseAdded(uint indexed appId, uint indexed responseIndex, address indexed responder, ResponseStatus status)` — emitted on `addResponse`.

Use these events to build a timeline UI or to power an off‑chain database.

---

## Security & Privacy Notes (beginner checklist)

* **Do not store full resumes on‑chain.** Use IPFS/Arweave/S3 and only store the content pointer (CID/URI) on chain.
* **Be careful with personal data.** Even a CID can point to PII — inform users where their data is stored and how to remove it off‑chain if necessary.
* **Access control:** Only grant `isResponder` to trusted HR wallets; losing a private key could allow malicious additions.
* **Gas costs:** Each on‑chain operation costs gas. Keep messages concise.

---

## Gas & Cost Tips

* Keep `message` fields short to reduce gas.
* Batch off‑chain work (indexing, heavy querying) in your backend; use events rather than on‑chain reads for UIs where possible.

---

## Next steps / Enhancements (ideas)

* Add off‑chain signature verification so applicants can cryptographically prove they created a specific off‑chain document before submission.
* Add application withdrawal: allow applicant to mark a request as withdrawn in an append‑only way (push a `Withdrawn` response) rather than deleting.
* Integrate with The Graph for fast querying and a dedicated subgraph.
* Build a React + Ethers UI that lists applications and shows the response timeline (I can scaffold one for you).
* Add role management via OpenZeppelin `AccessControl` for more granular permissions.

---

## Contributing

Contributions are welcome! If you want to propose improvements, open an issue or submit a pull request. Keep changes small and focused; include tests for new logic.

---

## License

This project is released under the **MIT License**.

---

If you want, I can also:

* Add a short React/Ethers starter UI that listens to events and displays timelines.
* Create a small test suite (Hardhat + ethers) with example tests for `submitApplication` and `addResponse`.

Tell me which of those you'd like next and I will add it.
