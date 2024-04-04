use https://jhustata.github.io/basic/_downloads/34a8255f06036b44354b3c36c5583d7e/transplants.dta, clear
do https://raw.githubusercontent.com/jhustata/basic/main/table1_fena.ado
table1_fena, var("age gender race bmi abo peak_pra prev_ki don_hgt don_wgt don_cod don_ecd dx")