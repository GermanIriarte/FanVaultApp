// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FanVault {
    address public owner;

    // ==== Whitelist por creador ====
    mapping(address => mapping(address => bool)) public whitelistByCreator;

    // ==== Estructura de datos ====
    mapping(string => string) private dataVault;
    mapping(string => address) public keyOwner;
    mapping(string => uint256) public keyPrice;
    mapping(address => string[]) public keysByOwner;
    mapping(address => address[]) public whitelistList;
    mapping(address => address[]) public whitelistRequests;


    constructor() {
        owner = msg.sender;
    }

    // ========== Funciones de whitelist ==========
    function addToMyWhitelist(address _fan) public {
    if (!whitelistByCreator[msg.sender][_fan]) {
        whitelistByCreator[msg.sender][_fan] = true;
        whitelistList[msg.sender].push(_fan); // Guardamos la dirección en la lista visible
    }
}

function removeFromMyWhitelist(address _fan) public {
    whitelistByCreator[msg.sender][_fan] = false;

    // Eliminar del array visible
    address[] storage list = whitelistList[msg.sender];
    for (uint i = 0; i < list.length; i++) {
        if (list[i] == _fan) {
            list[i] = list[list.length - 1];
            list.pop();
            break;
        }
    }
}

    function isInWhitelist(address _creator, address _fan) public view returns (bool) {
        return whitelistByCreator[_creator][_fan];
    }

    function getMyWhitelist() public view returns (address[] memory) {
    return whitelistList[msg.sender];
    }


    // ========== Guardar datos ==========
    function storeData(string memory _key, string memory _value) public {
        dataVault[_key] = _value;
        keyOwner[_key] = msg.sender; //le asociamos esa llave al propietario.
        keysByOwner[msg.sender].push(_key); //guardamos la clave asociada a un dueño en su arreglo de claves.
    }

    // ========== Modificar contenido ==========
    function updateData(string memory _key, string memory _newValue) public payable {
        if (msg.sender != keyOwner[_key]) {
            require(msg.value >= keyPrice[_key], "Pago insuficiente.");
        }
        dataVault[_key] = _newValue;
        keyOwner[_key] = msg.sender;
    }

    // ========== Acceso a contenido ==========
    function getData(string memory _key) public view returns (string memory) {
        address requester = msg.sender;
        address ownerOfKey = keyOwner[_key];

        require(
            requester == ownerOfKey || whitelistByCreator[ownerOfKey][requester],
            "No tienes acceso a este contenido"
        );

        return dataVault[_key];
    }

    // ========== Configuración de claves ==========
    function setPrice(string memory _key, uint256 _price) public {
        require(msg.sender == keyOwner[_key], "No eres el dueno de la clave.");
        keyPrice[_key] = _price;
    }

    function getMyKeys() public view returns (string[] memory) {
        return keysByOwner[msg.sender]; //trae las llaves del usuario actual.
    }

       function getKeysBy(address _creator) public view returns (string[] memory) {
        return keysByOwner[_creator]; // trae las llaves del creador.
    }


  function requestAccessToWhitelist(address _creator) public payable {
    address requester = msg.sender;
    // Evitar duplicados
    address[] storage requests = whitelistRequests[_creator];
    for (uint i = 0; i < requests.length; i++) {
        require(requests[i] != requester, "Ya enviaste solicitud.");
    }
    whitelistRequests[_creator].push(requester);
}

    function getMyWhitelistRequests() public view returns (address[] memory) {
        return whitelistRequests[msg.sender];
    }

    function approveRequest(address _fan) public {
        bool found = false;
        address[] storage requests = whitelistRequests[msg.sender];
        for (uint i = 0; i < requests.length; i++) {
            if (requests[i] == _fan) {
                found = true;
                // Eliminar solicitud
                requests[i] = requests[requests.length - 1];
                requests.pop();
                break;
            }
        }
        require(found, "No se encontro la solicitud.");
        whitelistByCreator[msg.sender][_fan] = true;
        whitelistList[msg.sender].push(_fan);
    }
}
