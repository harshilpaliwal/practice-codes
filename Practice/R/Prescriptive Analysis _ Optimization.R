#Q1
#Following1 customer demands, FitBite, a chain of Dutch walk-up fast food restaurants of the automatiek type, is preparing a 
#new Hamburger that is lower on calories, fat and sodium by mixing beef with chicken. 
#This new Hamburger should weight at least 125 grams and have at most 350 calories, 15 grams of fat, and 360 milligrams of sodium. 
#Each gram of beef used has 2.5 calories, 0.2 gram of fat, and 3.5 milligrams of sodium. 
#Each gram of chicken has 1.8 calories, 0.1 gram of fat, and 2.5 milligrams of sodium. 
#What is the mix that maximises beef content while meeting all requirements?

# Rules:
# 1. weight: -xb - xc <= -125
# 2. calories: 2.5xb + 1.8xc <= 350
# 3. fat: 0.2xb + 0.1xc <=15
# 4. sodium: 0.0035xb + 0.0025xc <= 360
# 5. max xb -> min -xb
# 6. -xb <= -0
# 7. -xc <= -0

library("lpSolve")
f.dir<-"min"
f.obj<-c(-1, 0) 
f.con<-matrix(c(-1,-1, 2.5, 1.8, 0.2, 0.1, 3.5, 2.5),ncol=2,byrow=TRUE) 
f.condir<-c("<=","<=","<=","<=")
f.rhs<-c(-125, 350, 15, 360) 
obj<-lp(f.dir,f.obj,f.con,f.condir,f.rhs) 
print(obj) # not very informative
if (obj$status == 0)
{
  print(paste("Success. Optimum at ", toString(obj$solution), " with objective function value ", 
              obj$objval))
  print("Checking which constraints are active (binding):")
  print(cbind(f.con %*% obj$solution, f.condir, f.rhs))
} else
{
  print("error: optimisation was not successful")
}



#Q2
#Dutch Farms operates 10 hectars of greenhouses in the Westland region of the Netherlands. 
# This area can be used to plant either tomatoes or bell peppers (paprikas). 
# Based on the previous’ years market prices, Dutch Farms estimates a profit of 450,000 Euro per hectar of planted tomatoes, 
# or 200,000 Euro per hektar of planted bell peppers. 
# As precaution against pests, insects, and market price changes, Dutch Farms wants to diversify its production. 
# Thus, it will not use more than 70% of its total greenhouse capacity on any single vegtable. 
# Furthermore, being a sustainable food producer, Dutch Frams has dediced to limit its use of irrigation water to a maximum of
# 70 units water per season. However, tomatoes require 10 units of water per hectar, while bell peppers require only 7 units.
# Dutch Farms is consulting you to help them developing a planting plan that maximises their profit while also 
# meeting their sustainability objective

# Rules:
# 1. -xt <= -0
# 2. -xb <= -0
# 3. max profit: 450000xt 200000xb -> min: -450000xt, -200000xb
# 4. greenhouse: xt <= 7, xw <= 7
# 5. 10xt + 7xb <= 70
# 6. land space: xt + xb <= 10

library("lpSolve")
f.dir<-"min"
f.obj<-c(-450000, -200000) 
f.con<-matrix(c(1, 0, 0, 1, 10, 7, 1, 1),ncol=2,byrow=TRUE) 
f.condir<-c("<=","<=","<=","<=")
f.rhs<-c(7, 7, 70, 10) 
obj<-lp(f.dir,f.obj,f.con,f.condir,f.rhs) 
print(obj) # not very informative
if (obj$status == 0)
{
  print(paste("Success. Optimum at ", toString(obj$solution), " with objective function value ", 
              obj$objval))
  print("Checking which constraints are active (binding):")
  print(cbind(f.con %*% obj$solution, f.condir, f.rhs))
} else
{
  print("error: optimisation was not successful")
}