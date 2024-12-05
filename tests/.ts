import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test tender creation",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('tender-system', 'create-tender', [
                types.ascii("Test Tender"),
                types.utf8("Test Description"),
                types.uint(100),
                types.uint(1000)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk().expectUint(0);
    }
});

Clarinet.test({
    name: "Test bid submission",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const bidder = accounts.get('wallet_1')!;
        
        // Create tender first
        let block = chain.mineBlock([
            Tx.contractCall('tender-system', 'create-tender', [
                types.ascii("Test Tender"),
                types.utf8("Test Description"),
                types.uint(100),
                types.uint(1000)
            ], deployer.address),
            
            // Submit bid
            Tx.contractCall('tender-system', 'submit-bid', [
                types.uint(0),
                types.uint(900)
            ], bidder.address)
        ]);
        
        block.receipts[1].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Test tender closure",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('tender-system', 'create-tender', [
                types.ascii("Test Tender"),
                types.utf8("Test Description"),
                types.uint(100),
                types.uint(1000)
            ], deployer.address),
            
            Tx.contractCall('tender-system', 'close-tender', [
                types.uint(0)
            ], deployer.address)
        ]);
        
        block.receipts[1].result.expectOk().expectBool(true);
    }
});
