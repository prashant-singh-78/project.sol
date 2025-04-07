// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvoiceFinancing {

    address public owner;
    uint public invoiceCount = 0;

    // Struct to represent an Invoice
    struct Invoice {
        uint id;
        string description;
        uint amount;
        address payable seller;
        address payable buyer;
        bool isFinanced;
        uint financedAmount;
    }

    // Mapping from invoice ID to Invoice details
    mapping(uint => Invoice) public invoices;

    // Event to log invoice creation
    event InvoiceCreated(uint id, address indexed seller, address indexed buyer, uint amount);

    // Event to log invoice financing
    event InvoiceFinanced(uint id, address indexed seller, address indexed financer, uint financedAmount);

    constructor() {
        owner = msg.sender;
    }

    // Modifier to ensure only the owner can perform specific actions
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized.");
        _;
    }

    // Modifier to ensure only the seller or buyer can perform certain actions
    modifier onlyInvolvedParties(uint _invoiceId) {
        require(msg.sender == invoices[_invoiceId].seller || msg.sender == invoices[_invoiceId].buyer, "You are not authorized to perform this action.");
        _;
    }

    // Function to create an invoice
    function createInvoice(string memory _description, uint _amount, address payable _buyer) public {
        invoiceCount++;
        invoices[invoiceCount] = Invoice({
            id: invoiceCount,
            description: _description,
            amount: _amount,
            seller: payable(msg.sender),
            buyer: _buyer,
            isFinanced: false,
            financedAmount: 0
        });
        emit InvoiceCreated(invoiceCount, msg.sender, _buyer, _amount);
    }

    // Function for invoice financing
    function financeInvoice(uint _invoiceId) public payable onlyInvolvedParties(_invoiceId) {
        require(invoices[_invoiceId].isFinanced == false, "Invoice already financed.");
        require(msg.value == invoices[_invoiceId].amount, "Financing amount must match the invoice amount.");

        // Transfer the amount to the seller
        invoices[_invoiceId].seller.transfer(msg.value);
        
        // Mark the invoice as financed
        invoices[_invoiceId].isFinanced = true;
        invoices[_invoiceId].financedAmount = msg.value;

        emit InvoiceFinanced(_invoiceId, invoices[_invoiceId].seller, msg.sender, msg.value);
    }

    // Function to retrieve an invoice
    function getInvoice(uint _invoiceId) public view returns (Invoice memory) {
        return invoices[_invoiceId];
    }

    // Function to withdraw contract balance (only owner)
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Function to get the contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

