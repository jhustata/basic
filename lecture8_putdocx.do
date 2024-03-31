//no log file because this is supposed to be called from lecture8_2020.do

//putdocx: make Word docs

//only works in Stata 15 or later
version 15

//do a "hello, world" with putdocx
putdocx clear

//start a new doc
putdocx begin

//required before "putdocx text" otherwise r(198) "no active paragraph"
putdocx paragraph

putdocx text ("Fourth quarter is almost over")

//NOTE: "putdocx save" requires the Word document to  be closed
//otherwise r(603) "failed to save document"
putdocx save doc1.docx, replace

//fancier text
putdocx begin

putdocx paragraph
putdocx text ("Fourth quarter is ")
putdocx text ("almost over"), bold
putdocx text (".")

putdocx paragraph
putdocx text ("Some of us are ")
putdocx text ("graduating"), underline
putdocx text ("!")
putdocx save doc2.docx, replace

//let's do a logistic regression and output the results
use transplants, clear
//who is more likely to get an ECD donor?
logistic don_ecd age i.abo bmi i.race i.gender

putdocx begin

//how many participants in the regression model?
count if e(sample)
local nn = r(N)

putdocx paragraph
putdocx text ///
    ("Table 1: Characteristics associated with receiving an ECD kidney,"), bold 

//write a macro right into the Word doc
putdocx text (" from Stata class dataset (N=`nn')"), bold

//NOTE: you have to run your model *right before* using "putdocx table=etable"
//(or replay it)
logistic
putdocx table model1_table = etable

//jump to a new page
putdocx pagebreak

//start a new paragraph
putdocx paragraph
putdocx text ///
    ("Figure 1: Age of DDKT recipients, stratified by donor type."), bold 

//make a figure
label define ecd 0 "SCD donor" 1 "ECD donor"
label values don_ecd ecd
graph box age, over(don_ecd) title("") //no title bc it's gonna have a caption
graph export figure1.png, replace width(2400)

putdocx paragraph, halign(center) //center the paragraph containing the image
putdocx image figure1.png, width(7)  //make it 7 inches wide
//width(15cm) = 15 cm. Can also be width(360pt) = 360 points (5 inches)
 

putdocx save doc3.docx, replace

