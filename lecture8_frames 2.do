//no log file because this is supposed to be called from lecture8_2022.do

//frames

//only works in Stata 16 or later
version 16

//frames demo

//create a new frame
capture frame drop donors
frame create donors

//load donors.dta into the new frame
frame donors: use donors, clear

//count how many records there are in frame "donors"
frame donors: count

//load in transplants.dta into our main frame
use transplants, clear
count

//do some more work in frame donors
frame donors {
    count 
    sum don_creat
    corr don_creat age_don
}

//switch to frame donors
frame change donors
count

//switch back to the default frame, which has transplants.dta loaded
frame change default
count

//copy existing data into a new frame
capture frame drop kids
frame put fake_id age gender race died if age<18, into(kids)

frame kids: list in 1/10, clean

frame kids {
     count
     sum age
}

count
sum age

frame change kids
count
sum age

frame change default
count
sum age

