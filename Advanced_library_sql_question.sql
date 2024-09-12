

select * from issued_status;
select * from return_status;
select * from books;
select * from branch;
select * from employees;
select * from members;

--Advanced Library SQL Question

"Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue."

-- ((issued_status==member)==book)==return_status
--flitter books which is return
--overdue>30

select ist.issued_member_id,
		m.member_name,
		bk.book_title,
		ist.issued_date,
		--rs.return_date,
		current_date - ist.issued_date as over_due_days
from issued_status as ist
join members as m
on ist.issued_member_id = m.member_id
join books as bk 
on ist.issued_book_isbn=bk.isbn
left join return_status as rs 
on ist.issued_id = rs.issued_id
where rs.return_date is null
and (current_date - ist.issued_date) > 30
order by 1;


"Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table)."

--Manual procedure

select * from issued_status;

select * from books
where isbn='978-0-451-52994-2'

update books
set status ='no'
where isbn='978-0-451-52994-2'


select * from issued_status
where issued_book_isbn='978-0-451-52994-2'

select * from return_status
where issued_id='IS130'

--------------
insert into return_status(return_id,issued_id,return_date,book_quality)
values('RS125','IS130',Current_date,'Good')

select * from return_status
where issued_id='IS130'


update books
set status ='yes'
where isbn='978-0-451-52994-2'

select * from books
where isbn='978-0-451-52994-2'

--------------*******************************************-----------------------------------------

--USING THE STORE PROCEDURE-----

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(10),p_issued_id varchar(10),p_book_quality varchar(15))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(80);
BEGIN
--all logic and code
	--inserting into return based on users input
	insert into return_status(return_id,issued_id,return_date,book_quality)
	values
	(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);

	select issued_book_isbn, issued_book_name into v_isbn , v_book_name
	from issued_status
	where issued_id =p_issued_id;

	update books
	set status ='yes'
	where isbn=v_isbn;

	RAISE NOTICE 'Thankyou for Returning the Book:- %',v_book_name;

END;
$$

CALL add_return_records();
----------------------------------------------------
select * from books;
--taking isbn=978-0-307-58837-1 showing status as 'no'

select * from issued_status
where issued_book_isbn ='978-0-7432-7357-1';
--taking isbn = IS135

select * from return_status--checking for the return status present or not 

delete  from return_status
where return_id = 'RS138'
-------------------------------------------
--testing the function

CALL add_return_records('RS140','IS136','Good');


"Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals."

--(issued_status==employees)=branch)=return)=book

CREATE TABLE branch_report
AS
	select 
		b.branch_id,
		b.manager_id,
		count(ist.issued_id) as No_of_book_issued,
		count(r.return_id) as No_of_book_return,
		sum(bk.rental_price) as Total_revenue 
	from issued_status as ist
	join employees as e 
	on ist.issued_emp_id = e.emp_id
	join branch as b
	on b.branch_id=e.branch_id
	join books as bk
	on ist.issued_book_isbn=bk.isbn
	left join return_status as r
	on ist.issued_id = r.issued_id
	group by 1,2
	order by 1,2;

select * from branch_report;

--------------------------------------------------------------------------------------------
"Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months."

CREATE TABLE active_member 
AS
select * from members 
where member_id IN (select distinct issued_member_id 
								from issued_status
								where issued_date >= current_date - INTERVAL '2 month');

select * from active_member;

----------------------------------------------------------------------------------------------------
"Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch."

--(issued=emp)=branch

select 
	e.emp_name,
	b.*,
	count(ist.issued_id) as No_of_book_issued
from issued_status as ist
join employees as e 
on ist.issued_emp_id=e.emp_id
join branch as b
on e.branch_id = b.branch_id
group by 1,2;
-------------------------------------------------------------------------------------------------------
"Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books."

select 
	m.member_name,
	ist.issued_book_name,
	count(ist.issued_id) as No_of_Time_issued
	from 
		issued_status as ist
	join
		members as m on ist.issued_member_id = m.member_id
	join
		return_status as r on ist.issued_id = r.issued_id
	where
		r.book_quality = 'Damaged'
	group by 1,2;

-------------------------------------------------------------------------------------------------------
"Task 19: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, 
and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book is currently not available."

select * from books;
select * from issued_status;


CREATE OR REPLACE PROCEDURE issue_book(p_issued_id varchar(10), p_issued_member_id varchar(30),p_issued_book_isbn varchar(50),p_issued_emp_id varchar(10))
LANGUAGE plpgsql
AS $$

DECLARE
	-- variable
	v_status varchar(10);
	v_book_title varchar(80);
BEGIN
	--logic
	select status,book_title into v_status,v_book_title
	from books
	where isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN

		INSERT INTO issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
		VALUES
		(p_issued_id,p_issued_member_id,v_book_title,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book issued and Recored successfully for Book :%',v_book_title;

	ELSE
		RAISE NOTICE 'Book is Not Available :-%',v_book_title;
	END IF;
		
END
$$
--////////////////////////////////////////////////////
select * from books;
--978-0-330-25864-8--yes
--978-0-375-41398-8--no
select * from issued_status;

-----------------
CALL issue_book('IS160','C106','978-0-375-41398-8','E106');

delete from issued_status where issued_id='IS160'

-----------------------------------------------------------------------------------------

"Task 20: Create Table As Select (CTAS) Objective: 
Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and 
the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines"

CREATE TABLE over_due_books 
AS
	select 
		ist.issued_member_id as Member_id,
		m.member_name,
		count(ist.issued_member_id) as No_of_books,
		max(current_date - ist.issued_date) as No_of_dues,
		sum((current_date - ist.issued_date)*0.5) as Total_fine	
	from 
		issued_status as ist
	join
		members as m on ist.issued_member_id = m.member_id
	join
		books as b on ist.issued_book_isbn=b.isbn
	left join 
		return_status as r on ist.issued_id=r.issued_id
	where 
		r.return_id is null
	and 
		(current_date - ist.issued_date)>30
	group by 1,2;

select * from over_due_books;