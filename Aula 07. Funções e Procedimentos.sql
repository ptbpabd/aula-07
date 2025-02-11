-- Slide 4
-- Criação da função
CREATE FUNCTION dbo.dept_count (@dept_name varchar(20)) 
RETURNS INT AS
BEGIN
	DECLARE @d_count INT;
	SELECT @d_count = COUNT(*) FROM dbo.instructor WHERE instructor.dept_name = @dept_name 

	RETURN (@d_count);
END

-- Execuções da função

SELECT dbo.dept_count('Accounting');

SELECT dept_name, budget, dbo.dept_count (dept_name)
FROM department
WHERE dbo.dept_count (dept_name) >= 3;

-- Slide 6
-- Criação da função
CREATE FUNCTION dbo.instructor_of (@dept_name char(20))
RETURNS TABLE  
AS
RETURN (SELECT ID, name, dept_name, salary 
        FROM dbo.instructor WHERE instructor.dept_name = @dept_name);

-- Execução da função
SELECT * FROM dbo.instructor_of('Accounting');

-- Slide 7
-- Criação do procedimento
CREATE PROCEDURE dbo.dept_count_proc @dept_name varchar(20),
                                     @d_count INT OUT
AS
    SET NOCOUNT ON; -- Desativa as mensagens que o SQL Server envia ao cliente após a execução de qualquer instrução
    SET @d_count = (SELECT COUNT(*) FROM dbo.instructor WHERE dbo.instructor.dept_name = @dept_name);

-- Execução do procedimento
DECLARE @d_count int
EXEC dbo.dept_count_proc 'Accounting', @d_count OUT; 
SELECT @d_count;

-- Slide 11
-- Criação do procedimento
CREATE PROCEDURE dbo.salaryStatus @salary_limit NUMERIC(8,2)
AS
	SET NOCOUNT ON;
	DECLARE @instructorName AS NVARCHAR(50)
	DECLARE @instructorDepartment AS NVARCHAR(50)
	DECLARE @instructorSalary AS NUMERIC(8,2)
	DECLARE @LocationTVP AS TABLE (instructorName NVARCHAR(50), 
	                               instructorDepartment NVARCHAR(50),
	                               instructorSalary NUMERIC(8,2),
	                               instructorSalaryStatus NVARCHAR(50));
	
	DECLARE instructor_Cursor CURSOR
	FOR
	SELECT name, dept_name, salary FROM dbo.instructor;
	
	OPEN instructor_Cursor;
	
	FETCH NEXT
	FROM instructor_Cursor
	INTO @instructorName, @instructorDepartment, @instructorSalary;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @instructorSalary > @salary_limit
			BEGIN
	       		PRINT 'Salário MAIOR 50000' + ',' + @instructorName + ',' + @instructorDepartment + ',' + CAST(@instructorSalary as nvarchar(20));
	       		INSERT INTO @LocationTVP (instructorName, instructorDepartment, instructorSalary, instructorSalaryStatus) VALUES (@instructorName, @instructorDepartment, @instructorSalary , 'High salary');
	        END 
	    ELSE
	       BEGIN
	       		PRINT 'Salário MENOR 50000' + ',' + @instructorName + ',' + @instructorDepartment + ',' + CAST(@instructorSalary as nvarchar(20))
	       		INSERT INTO @LocationTVP (instructorName, instructorDepartment, instructorSalary, instructorSalaryStatus) VALUES (@instructorName, @instructorDepartment, @instructorSalary , 'Low salary');
	       END
	    FETCH NEXT
	    FROM instructor_Cursor    
	    INTO @instructorName, @instructorDepartment, @instructorSalary;
	END;	
	
	CLOSE instructor_Cursor;
	
	DEALLOCATE instructor_Cursor;
	
	SELECT * FROM @LocationTVP ORDER BY instructorSalary;
	
-- Execução do procedimento	
EXEC dbo.salaryStatus 35023.17;

-- Eliminar Procedure
DROP PROCEDURE dbo.salaryStatus;





