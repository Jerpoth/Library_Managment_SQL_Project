SELECT * FROM books;
SELECT * FROM BRANCH;
SELECT * FROM Employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;



---Project Task---

--Task 1. 
--Create a New Book Record -- 
"978-1-60129-456-2', 'To Kill a Mockingbird',
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn,book_title,category,rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2','To kill a Mockingbird','Classic',6.00,'yes','Harper Lee', 'J.B. Lippincott & Co.')

--Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak st'
Where member_id = 'C103';

--Task 3: Delete a Record from the Issued Status Table -- 
"Objective: Delete the record with 
issued_id = 'IS121' from the issued_status table."

DELETE FROM issued_status
WHERE issued_id = 'IS121';


"Task 4: Retrieve All Books Issued by a Specific Employee
Objective: Select all books issued by the employee with emp_id = 'E101'."

Select * from issued_status
where issued_emp_id ='E101';


"Task 5: List Members Who Have Issued More Than One Book 
Objective: Use GROUP BY to find members who have issued more than one book."

select issued_member_id, count(issued_member_id) 
from issued_status
group by 1
having count(issued_member_id) >1;

"3. CTAS (Create Table As Select)
Task 6: Create Summary Tables: 
Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**"

CREATE TABLE book_issued_count as 
SELECT b.isbn,b.book_title,count(ist.issued_id) as No_count
FROM books as b join issued_status as ist 
on b.isbn=ist.issued_book_isbn
group by 1;

select * from book_issued_count;


"4. Data Analysis & Findings
The following SQL queries were used to address specific questions:
Task 7. Retrieve All Books in a Specific Category:"

select * from BOOKS
where CATEGORY='Classic';

"Task 8: Find Total Rental Income by Category:"

select b.category,sum(b.rental_price) as Amount,count(ist.issued_id) as no_count
from books as b join issued_status as ist 
on b.isbn = ist.issued_book_isbn
group by 1;


"List Members Who Registered in the Last 180 Days:"
select * from members
where reg_date >= current_date - INTERVAL '180 DAYS';


"List Employees with Their Branch Manager's Name and their branch details:"

select e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    e2.emp_name as manager,
	b.*
from employees as e1 
join branch as b 
on e1.branch_id=b.branch_id
join employees as e2 
on b.manager_id = e2.emp_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7usd:
drop table if exists expensive_books;
create table Expensive_books as 
select * from books
where rental_price >'7.00';

select * from expensive_books;

--Task 12: Retrieve the List of Books Not Yet Returned

select distinct iss.issued_book_name 
from issued_status as iss
left join return_status as rs
on iss.issued_id=rs.issued_id
where rs.return_id is null;




