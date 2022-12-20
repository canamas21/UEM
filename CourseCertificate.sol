// Version de solidity del Smart Contract
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

// Informacion del Smart Contract
// Nombre: Certificado
// Logica: Implementa la creación de un Certificado de aprovechamiento de un curso

// Declaracion del Smart Contract - CourseCertified
contract CourseCertificate {

    // ----------- Variables (datos) -----------
    // Información del curso
    string private description;
    string private center;
    string private courseData;
    uint256 private certifiedPrice;
    mapping(address => bool) public whitelist;
    mapping(address => User) public users;
    mapping(address => bool) public verifieds;

    // Centro emisor del certificado
    address payable public owner;

    // Usuarios
    struct User{
        string name;
        address _address;
        bool payed;
    }
    
    // Estado del contrato
    bool private activeContract;

    //---------Modificadores de las funciones--------------
    //Verifica que és el propietario del contrato
    modifier ownerFilter (address _owner){
        require(_owner == owner);
        _;
    }
    
     //Verifica que se paga el precio estipulado por el contrato
    modifier priceFilter (uint256 _price){
        require(_price == certifiedPrice);
        _;
    }

    // ----------- Constructor -----------
    // Uso: Inicializa el Smart Contract - CourseCertified con: description, center, courseData y coursePrice
        constructor() payable {
        
        // Inicializo el valor a las variables (datos)
        
        center = "IES Marc Ferrer";
        courseData = "December 2022";
        description =  "has completed the teacher training course in the use of ICTs"
        "              Course contents: - Gestib teacher's notebook"
        "                               - Moodle"
        "                               - Mentimeter"
        "             done in"; 
        certifiedPrice = 50000;
        owner = payable(msg.sender);
        activeContract = true;
    }


    // ------------ Funciones que modifican datos (set) ------------

    // Funcion
    // Nombre: addCertificableUsers
    // Uso:    Permite al propietario del contrato (centro) registrar las adresses
    // que pueden certificar el curso
    function addCertificableUsers(address _newEntry) public ownerFilter(msg.sender){
        require(activeContract, "The contract is Inactive");
         whitelist[_newEntry] = true;   
    }

    // Funcion
    // Nombre: removeCertificableUsers
    // Uso:    Permite al propietario del contrato (centro) eliminar adresses 
    // que no deben certificar el curso en caso de añadirlas por error
    function removeCertificableUsers(address _newEntry) public ownerFilter(msg.sender){
        require(activeContract, "The contract is Inactive");
        require(whitelist[_newEntry], "Previous not in whitelist");
         whitelist[_newEntry] = false;
    }

    // Funcion
    // Nombre: addUser
    // Uso:    Permite a cualquier usuario crear su certificado, siempre y cuando
    // su address esté previamente registrada
    function addUser(string memory _name) public payable priceFilter(msg.value) {
        require(activeContract, "The contract is Inactive");
        require(verifieds[msg.sender] == false, "You have already certified");
        require(whitelist[msg.sender], "You do not meet the requirements to certify this course");
        users[msg.sender].name = _name;
        users[msg.sender]._address = msg.sender;
        users[msg.sender].payed = true;
        verifieds[msg.sender] = true;
    }

    // Funcion
    // Nombre: transferBalance
    // Uso:    Transfiere el balance de la cuenta del contrato al propietario
    function transferBalance() public payable ownerFilter(msg.sender){
        require(activeContract, "The contract is Inactive");
        owner.transfer(address(this).balance);    
    }


    // ------------ Funciones que consultan datos (get) ------------

    // Funcion
    // Nombre: certificateUser
    // Logica: Permite a cualquier usuario verificar la certificación de otro
    function certificateUser(address _unverifiedaddress) public view returns (string memory, string memory, string memory, string memory){
       require(activeContract, "The contract is Inactive");
       require(verifieds[_unverifiedaddress], "This user has not certified");
        return (users[_unverifiedaddress].name, description, center, courseData);
    }  

    
    // ------------ Funciones de panico/emergencia ------------

    // Funcion
    // Nombre: stopCourseCertified
    // Uso:    Para el contrato y ya no se puede certificar
    function stopCourseCertified() public payable ownerFilter(msg.sender){
        require(activeContract, "The contract is Inactive");
        // Se para la certificación
        owner.transfer(address(this).balance);
        activeContract = false;      
    }
}
