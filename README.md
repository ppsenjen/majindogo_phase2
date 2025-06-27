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

### 4. Getting three field surveyors with the most location visits.
I successfully achieved this by utilizing both Common Table Expressions (CTEs) and direct table joins, exploring both approaches keenly. 
I also leveraged a CTE specifically to retrieve the names and email addresses of the top employees based on their highest visit count. 
Through these exercises, I've gained a clear understanding of the power and versatility of CTEs in structuring and solving complex SQL queries.

| assigned_employee_id | employee_name | email                   | phone_number  | num_of_visits |
| :------------------- | :------------ | :---------------------- | :------------ | :------------ |
| 1                    | Bello Azibo   | bello.azibo@ndogowater.gov | +996438647863 | 3708      |
| 2                    | Pili Zola     | pili.zola@ndogowater.gov | +998224789333 | 3676         |
| 3                    | Rudo Imani    | rudo.imani@ndogowater.gov | +990469726483 | 3539         |

### 5. Analyzing locations
To understand the distribution of water sources throughout Maji Ndogo, I analyzed the `province_name`, `town_name`, and `location_type` 
columns within the location table.
Looking at the data, it's quite clear that most of Maji Ndogo's water sources, at least according to our survey, are found spread out among the smaller, rural communities. What's also reassuring is that when we tally up the sources by province, they all seem to have a fairly similar number. This tells us our survey really does a good job of representing every province across Maji Ndogo.

<b> Records per town</b>                                                      

| town_name | record_per_town |
| :-------- | :-------------- |
| Rural     | 23740           |
| Harare    | 1650            |
| Amina     | 1090            |
| Lusaka    | 1070            |
| Mrembo    | 990             |


 <b> Records per province </b>

| province_name | record_per_province |
| :------------ | :------------------ |
| Kilimani      | 9510                |
| Akatsi        | 8940                |
| Sokoto        | 8220                |
| Amanzi        | 6950                |
| Hawassa       | 6030                |

