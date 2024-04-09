----------------------------------------------------------Beginner Level---------------------------------------------------------------------

SELECT * FROM `da999-417210.musicstoredata.employee` LIMIT 1000;

-- 1. Sernior Most Employee
select first_name,last_name,birthdate from `da999-417210.musicstoredata.employee`
order by birthdate asc
limit 1;

-- 2. senior most employee based on job title
select first_name,last_name,levels from `da999-417210.musicstoredata.employee`
order by  levels desc
limit 1;

-- 3. Which countries have the most Invoices?
select count(billing_country) as most_billing_country, billing_country from `da999-417210.musicstoredata.invoice`
group by billing_country
order by most_billing_country desc; 

-- 4. What are top 3 values of total invoice?
select total from `da999-417210.musicstoredata.invoice`
order by total desc
limit 3;

-- 5. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, count(billing_city) as most_billing_city, sum(total) as total_billing  from `da999-417210.musicstoredata.invoice`
group by billing_city
order by total_billing desc;

-- 6. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select customer_table.customer_id,customer_table.first_name, customer_table.last_name, sum(invoice_table.total) as total from `da999-417210.musicstoredata.customer` as customer_table
join `da999-417210.musicstoredata.invoice`  as invoice_table
on customer_table.customer_id=invoice_table.customer_id
group by customer_table.customer_id,customer_table.first_name,customer_table.last_name
order by total desc
limit 1;



--------------------------------------------------------Intermediate Level-------------------------------------------------------------------------------
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select customer_table.email, customer_table.first_name, customer_table.last_name from `da999-417210.musicstoredata.customer` as customer_table 
join `da999-417210.musicstoredata.invoice` as invoice_table
on customer_table.customer_id=invoice_table.invoice_id 
join `da999-417210.musicstoredata.invoice_line` as invoice_line_table 
on invoice_table.invoice_id=invoice_line_table.invoice_line_id  
join `da999-417210.musicstoredata.track` as track_table 
on invoice_line_table.invoice_line_id=track_table.track_id
join `da999-417210.musicstoredata.genre` as genre
on track_table.genre_id=genre.genre_id 
where genre.name='Rock'
order by customer_table.email;


-- Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

select artist.artist_id, artist.name, count(track.genre_id) as genre_id_count from da999-417210.musicstoredata.artist as artist 
join da999-417210.musicstoredata.album as album
on artist.artist_id=album.artist_id 
join da999-417210.musicstoredata.track as track 
on album.album_id=track.album_id 
join da999-417210.musicstoredata.genre
on track.genre_id=genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id,artist.name,track.genre_id
order by genre_id_count desc 
limit 10;

-- Return all the track names that have a song length longer than the average song length.Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select track_id, name, milliseconds from da999-417210.musicstoredata.track 
where milliseconds > (select avg(milliseconds) from da999-417210.musicstoredata.track)
order by milliseconds desc;



------------------------------------------Advance----------------------------------------------------------------------

-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

with best_selling_artist as (
  select artist.artist_id, artist.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales from `da999-417210.musicstoredata.artist` as artist
  join da999-417210.musicstoredata.album as album 
  on artist.artist_id=album.artist_id 
  join `da999-417210.musicstoredata.track` as track
  on album.album_id=track.album_id
  join `da999-417210.musicstoredata.invoice_line` as invoice_line
  on track.track_id=invoice_line.track_id 
  group by 1,2
  order by 3 desc
  limit 1
  ) 
  select customer.customer_id,customer.first_name, customer.last_name, bsa.name, sum(invoice_line.unit_price * invoice_line.quantity) as total_spent from `da999-417210.musicstoredata.invoice` as invoice
  join da999-417210.musicstoredata.customer as customer on customer.customer_id=invoice.customer_id
  join da999-417210.musicstoredata.invoice_line as invoice_line on invoice.invoice_id=invoice_line.invoice_id 
  join da999-417210.musicstoredata.track as track on invoice_line.track_id=track.track_id 
  join da999-417210.musicstoredata.album as album on track.album_id=album.album_id 
  join best_selling_artist as bsa on album.artist_id=bsa.artist_id
  group by 1,2,3,4
  order by 5 desc;


-- 2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
with most_popular_genre as (
  select count(invoice_line.quantity) as purchases, genre.name, genre.genre_id, customer.country, ROW_NUMBER() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno 
  from da999-417210.musicstoredata.customer as customer 
  join da999-417210.musicstoredata.invoice as invoice on customer.customer_id=invoice.customer_id
  join da999-417210.musicstoredata.invoice_line as invoice_line on invoice.invoice_id=invoice_line.invoice_id
  join da999-417210.musicstoredata.track on invoice_line.track_id=track.track_id
  join da999-417210.musicstoredata.genre on track.genre_id=genre.genre_id
  group by 2,3,4
  order by 4 asc, 1 desc
)
select * from most_popular_genre where rowno<=1;

-- 3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
 
with customer_countryspecific as (
  select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, sum(invoice.total) as purchase, row_number() over(partition by invoice.billing_country order by sum(invoice.total)) as rowno
  from da999-417210.musicstoredata.customer as customer
  join da999-417210.musicstoredata.invoice as invoice on customer.customer_id=invoice.customer_id 
  group by 1,2,3,4
  order by 4, 5 desc  
) 
select * from customer_countryspecific where rowno<=1;




  



                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        