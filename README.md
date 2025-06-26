# majindogo_phase2
In this phase I'll start by getting a look at the database tables again to get the feel.
## Cleaning the Employee Table.
### 1. email
The employee table, which contains information about all our workers, needs to be updated because it's missing email addresses. Since we'll be sending reports and figures to these employees, adding their emails is essential. Fortunately, obtaining the email addresses for our department is straightforward, as they all follow the format of `first_name.last_name@ndogowater.gov`.

<b> I determined the email address for each employee by: </b>
- selected the employee_name column
- replaced the space with a full stop
- made it lowercase
- Joined it all together
- I then updated the database again with these email addresses,

 ###  2. phone numbers
The phone numbers length should be 12 characters long but it is 13 characters. I need to check on that.
The problem comes from an invisible space at the end of the number, which would prevent any automated SMS messages from being successfully delivered. 
I used the function, `TRIM(column)`, to address it by removing any leading or trailing spaces from the string.

### 3. Looking where our employees live (counting)
From the query results I noticed most people in maji ndogo live in the rural parts
town_name num_employees

| num_of_employee | town| 
|----------|----------|
| 29 | Rural | 
| 6 | Dahabu | 

###3 Getting three field surveyors with the most location visits.
