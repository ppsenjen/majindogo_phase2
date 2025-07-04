# Solving  majindogo's water crisis using MySQL (phase_two)
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

Joining the provinces to towns in a single output

| provincename | town_name | records per town |
| :----------- | :-------- | :---------- |
| Akatsi       | Harare    | 800         |
| Akatsi       | Kintampo  | 780         |
| Akatsi       | Lusaka    | 1070        |
| Akatsi       | Rural     | 6290        |
| Amanzi       | Abidjan   | 400         |


### 6. looking at the number of records for each location type
from the table below we can see that there are more rural sources than urban.
Used a subquery to calculate the percentage of each source to the total 

| location type | num of sources | Percentage_total |
| :------------ | :------------- | :--------- |
| Rural         | 23740          | 60%        |
| Urban         | 15910          | 40%        |


### 7. Diving into water sources
<b>How many wells, taps and rivers are there?</b>
| water sources     | number of water sources |
|-------------------|-------|
| well              | 17383 |
| tap_in_home       | 7265  |
| tap_in_home_broken| 5856  |
| shared_tap        | 5767  |
| river             | 3379  |

<b>How many people share particular types of water sources on average?</b>
| water sources  | Avg people per source |
|-------------------|-------|
| shared_tap        | 2071  |
| tap_in_home       | 644   |
| tap_in_home_broken| 649   |
| river             | 699   |
| well              | 279   |

From the result we should focus on improving shared taps first.

N/B - On average, about 6 people live together in one home and share a single tap within that household.
So, if the data shows, for example, 644 "tap_in_home" records, it doesn't mean just 644 taps. Because each record represents a tap shared by roughly 6 people, it actually translates to about 100 actual, individual taps (644 divided by 6). The same logic applies to "tap_in_home_broken" records.
In essence, the data gives a broad household count, but the real number of individual taps is much higher due to shared usage within homes.

<b>The total number of people served by each type of water source in total</b>
| Water Source        | Percentage (%) people  |
|---------------------|----------------|
| shared_tap          | 44          |
| tap_in_home         | 17          |
| tap_in_home_broken  | 14          |
| river               | 9           |
| well                | 18         |

By adding tap_in_home and tap_in_home_broken together, we see that 31% of people have water infrastructure installed in their homes, but 45%
(14/31) of these taps are not working! This isn't the tap itself that is broken, but rather the infrastructure like treatment plants, reservoirs, pipes, and
pumps that serve these homes that are broken.



# 8. Starting on the solution
The simple approach is to fix the things that affect most people first.I will use a query that ranks each type of source based
on how many people in total use it. using rank() also means using the window function.If someone has a tap in their home, they already have the best source available. Since we can’t do anything more to improve this,I have removed the tap_in_home from the ranking before running the query.
I have used a CTE (Common Temporary Expression), rabk functions and aggregated values to achieve this.
We should start by fixing the shared taps first then tap_in_home_broken,river  and lastly well.

Another question arises, which shared taps or wells should be fixed first? We can use
the same logic; the most used sources should really be fixed first.
Joined the location table to the water source table to get the address of the water sources. Then used the window function to assign the ranks based on the number of people served.

# 9. Analyzing the queues

Some of questions that should be answered here;
### 1. How long did the survey take?
I used the date diff function to calculate the period the survey took. Surprisingly it took 924 days.
Which is about 2 and a half years.

### 2. What is the average total queue time for water?
Many sources like taps_in_home have no queues. These
are just recorded as 0 in the time_in_queue column, so when calculating averages, exclude those rows using NUllIF()
Queue time = 123 min. So on average, people take two hours to fetch water if they don't have a tap in their homes.

### 3. What is the average queue time on different days?
grouped data by day of the week to calculate this.
From the table most people queue  on on Fridays.

| Day of Week | Average Time (minutes) |
|-------------|------------------------|
| Friday      | 181.42                 |
| Thursday    | 178.46                 |
| Tuesday     | 176.86                 |
| Wednesday   | 174.57                 |
| Monday      | 173.11                 |
| Saturday    | 172.61                 |
| Sunday      | 169.45                 |

### 4. What time during the day do people collect water?
From the table we can see that mornings and evenings are the busiest,It looks like people collect water before and after work.
| Hour of Day | Average Queue Time (minutes) |
|-------------|------------------------------|
| 06:00       | 148.93                       |
| 07:00       | 149.13                       |
| 08:00       | 148.89                       |
| 09:00       | 117.76                       |
| 10:00       | 113.89                       |
| 11:00       | 110.69                       |
| 12:00       | 111.52                       |
| 13:00       | 115.05                       |
| 14:00       | 114.24                       |
| 15:00       | 114.21                       |
| 16:00       | 114.08                       |
| 17:00       | 148.79                       |
| 18:00       | 146.82                       |
| 19:00       | 167.70                       |

### Further using the case() statement to break the hours by day used to queue for water.
From the table below we can find a pattern.
1. Queues are very long on a Monday morning and Monday evening as people rush to get water.
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue pretty much twice as long on Saturdays compared to the weekdays. It looks like people spend their Saturdays queueing
for water, perhaps for the week's supply?
4. The shortest queues are on Sundays, and this is a cultural thing. The people of Maji Ndogo prioritise family and religion, so Sundays are spent
with family and friends.

| Hour   | Sun | Mon | Tue | Wed| Thur | Frid | Sat |
|--------|---------|---------|---------|---------|---------|---------|---------|
| 06:00  | 79      | 190     | 134     | 112     | 134     | 153     | 153     |
| 07:00  | 82      | 186     | 128     | 111     | 139     | 156     | 156     |
| 08:00  | 86      | 183     | 130     | 119     | 129     | 153     | 153     |
| 09:00  | 84      | 127     | 105     | 94      | 99      | 107     | 107     |
| 10:00  | 83      | 119     | 99      | 89      | 95      | 112     | 112     |
| 11:00  | 78      | 115     | 102     | 86      | 99      | 104     | 104     |
| 12:00  | 78      | 115     | 97      | 88      | 96      | 109     | 109     |
| 13:00  | 81      | 122     | 97      | 98      | 101     | 115     | 115     |
| 14:00  | 83      | 127     | 104     | 92      | 96      | 110     | 110     |
| 15:00  | 83      | 126     | 104     | 88      | 92      | 110     | 110     |
| 16:00  | 83      | 127     | 99      | 90      | 99      | 109     | 109     |
| 17:00  | 79      | 181     | 135     | 121     | 129     | 151     | 151     |
| 18:00  | 80      | 174     | 122     | 113     | 132     | 158     | 158     |
| 19:00  | 127     | 159     | 145     | 176     | 137     | 103     | 103     |

# Water Accessibility and infrastructure summary report
This survey aimed to identify the water sources people use and determine both the total and average number of users for each source.
Additionally, it examined the duration citizens typically spend in queues to access water.

# Insights from the data
1. Most water sources are rural.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group, 45% face non-functional systems due to issues with pipes,
pumps, and reservoirs.
4. 18% of our people are using wells of which, but within that, only 28% are clean..
5. Our citizens often face long wait times for water, averaging more than 120 minutes.
6. In terms of queues:
- Queues are very long on Fridays.
- Queues are longer in the mornings and evenings.
- Wednesdays and Sundays have the shortest queues.

  # Proposed Solutions
  1. We want to focus our efforts on improving the water sources that affect the most people.
- Most people will benefit if we improve the shared taps first.
- Wells are a good source of water, but many are contaminated. Fixing this will benefit a lot of people.
- Fixing existing infrastructure will help many people. If they have running water again, they won't have to queue, thereby shorting queue times for
others. So we can solve two problems at once.
- Installing taps in homes will stretch our resources too thin, so for now, if the queue times are low, we won't improve that source.
2. Most water sources are in rural areas. We need to ensure our teams know this as this means they will have to make these repairs/upgrades in
rural areas where road conditions, supplies, and labour are harder challenges to overcome.

## Proposed Practical solutions to current challenges in Maji Ndogo
1. If communities are using rivers, we can dispatch trucks to those regions to provide water temporarily in the short term, while we send out
crews to drill for wells, providing a more permanent solution.
2. If communities are using wells, we can install filters to purify the water. For wells with biological contamination, we can install UV filters that
kill microorganisms, and for *polluted wells*, we can install reverse osmosis filters. In the long term, we need to figure out why these sources
are polluted.
3. For shared taps, in the short term, we can send additional water tankers to the busiest taps, on the busiest days. We can use the queue time
 to send tankers at the busiest times. Meanwhile, we can start the work on installing extra taps where they are needed.
According to UN standards, the maximum acceptable wait time for water is 30 minutes. With this in mind, our aim is to install taps to get
queue times below 30 min.
4. Shared taps with short queue times (< 30 min) represent a logistical challenge to further reduce waiting times. The most effective solution,
installing taps in homes, is resource-intensive and better suited as a long-term goal.
5. Addressing broken infrastructure offers a significant impact even with just a single intervention. It is expensive to fix, but so many people
can benefit from repairing one facility. For example, fixing a reservoir or pipe that multiple taps are connected to. We will have to find the
commonly affected areas though to see where the problem actually is.
