// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library Address {

    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }
}

interface IERC721Receiver {

    function onERC721Received(
        
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(

        address from,
        address to,
        uint256 tokenId

    ) external;

    function transferFrom(

        address from,
        address to,
        uint256 tokenId

    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(

        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

contract TokenERC721 is IERC721 {

    using Address for address;
    string private _name;
    string private _symbol;
    string private _token_uri;
    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balances;

    constructor(string memory name, string memory symbol, string memory token_uri) {

        _name = name;
        _symbol = symbol;
        _token_uri = token_uri;

    }

    function balanceOf(address owner) public view virtual override returns(uint256) {

        require(owner != address(0), "Balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns(address) {
        address owner = _owner[tokenId];
        require(owner != address(0), "owner query for none existent token");
        return owner;
    }

    function _exist(uint256 tokenId) internal view virtual returns(bool) {
        return _owner[tokenId] != address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(!_exist(tokenId), "Token available");

        _balances[to] += 1;
        _owner[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        _safeTransfer(from, to, tokenId, _data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, _data), "transfer to non ERC721Receiver implementer");
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual{
        require(TokenERC721.ownerOf(tokenId) == from, "incorrect owner");
        require(to != address(0), "transfer to zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    } 
}