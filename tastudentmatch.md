First letter of Student's Last Name

# HW3
1. SLBTM -> Ning Meng   
2. YZRVU -> Natalie Daya Malek
3. KGHJW -> Xujun Gu
4. FIDXC -> Maya Aboumrad
5. APEON -> Darien Colson-Fearon

# HW5

1. MIFJD -> Ning Meng   
2. HYGUZ -> Natalie Daya Malek
3. QAKSN -> Xujun Gu
4. LOPXR -> Maya Aboumrad
5. ETCWVB -> Darien Colson-Fearon

# HW6

1. VRUBZN -> Ning Meng   
2. QEIYF -> Natalie Daya Malek
3. CDTMK -> Xujun Gu
4. WSGPO -> Maya Aboumrad
5. HLXAJ -> Darien Colson-Fearon

# HW7 ( 🎓 Graduating students to be graded by 9am 05/17)

1. WGEBV -> Ning Meng   
2. DFJTZS -> Natalie Daya Malek
3. APQRK -> Xujun Gu
4. CNIYX -> Maya Aboumrad
5. MHOUL -> Darien Colson-Fearon


```stata
qui {
    
    
    if 1 { //N=26
        
        cls
        clear
        set obs 26
        
        capture log close 
        log using tokenize.log, replace  
        
    }
    
    if 2 { //Int 1-26
        
        egen lastname = seq(), f(1) t(26)
        tostring lastname, replace 
        tokenize "`c(ALPHA)'" 
        
    }

    if 3 { //Tokenize
        
        forval i = 1/26 {
            
            replace lastname = "``i''" if lastname == "`i'" 
            
        }
        
    }
    
    if 4 { //Randomly
        
        //set seed 340600 //HW3 seed
		//set seed 340700 //HW5 seed
		//set seed 340800 //HW6 seed
		set seed 340900 //HW7 seed
        g randomorder=runiform()
        sort random  
        drop random    
        
    }
    
    if 5 { //Output
        
        noi list 
        log close 
        
    }

}
```