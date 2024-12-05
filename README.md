# Public Tender System

A transparent blockchain-based public tender system implemented on the Stacks blockchain using Clarity.

## Features

- Create public tenders with detailed specifications
- Submit sealed bids for tenders
- Automatic winner selection based on lowest valid bid
- Complete transparency in tender process
- Immutable record of all bids and tender details
- Owner-controlled tender lifecycle management

## Contract Functions

- create-tender: Create a new public tender
- submit-bid: Submit a bid for an active tender
- close-tender: Close an active tender
- get-tender: View tender details
- get-bid: View bid details

## Security Features

- Only contract owner can create and close tenders
- Bids must meet minimum bid requirements
- Automatic validation of tender status and bid amounts
