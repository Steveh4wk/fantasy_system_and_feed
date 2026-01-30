-- Database tables creation script  
  
CREATE TABLE IF NOT EXISTS vampire_states (  
    identifier VARCHAR(50) PRIMARY KEY,  
    state_data LONGTEXT NOT NULL  
);  
  
CREATE TABLE IF NOT EXISTS lycan_states (  
    identifier VARCHAR(50) PRIMARY KEY,  
    state_data LONGTEXT NOT NULL  
); 
