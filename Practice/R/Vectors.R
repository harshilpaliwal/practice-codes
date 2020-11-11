#vectors=arrays (collection of values of same data types)
#use c() to create vectors

c(1, 2, 3, 4, 5)
class(c)
number<-c(1, 2, 3, 4, 5)
class(number)
ls()

#giving names to your vectors
name<-c("one", "two", "three", "four", "five")
names(number)<-name
number

#another way to do this
cards<-c(spades=1, hearts=2, club=3, diamond=4)
cards

str(cards)

#everything here is a vector. Even variables are vectors of length 1.
length(cards)
height<-1
length(height)

#vector arithmetics
earnings<-c(20, 200, 2000)
earnings-2
earnings+10
earnings*10-10

expenses<-c(10, 3000, 40)

earnings-expenses
earnings>expenses

#vector subsetting - creating new vector from existing vector
cards<-c(spades=1, hearts=2, club=3, diamond=4)
newcard<-cards[1]
newcard
newcard<-cards[c(1,2)]
newcard
newcard<-cards[c("spades", "club")]
newcard
newcard<-cards[c(TRUE, TRUE, FALSE, TRUE)]
newcard

#if the length of logic vector is less than the length of the vector which is being operated,
#R simply replicates the patter to match the length
#true, false becomes true, false, true, false.....
logicvector<-c(TRUE, FALSE)
newcard<-cards[c(logicvector)]
newcard