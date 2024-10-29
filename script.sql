-- ----------------------------------------------------------------
-- 1 Base de dados e criação de tabela
--escreva a sua solução aqui

CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    activity INT,
    salary INT,
    mother_edu INT,
    father_edu INT,
    prep_study INT,
    prep_exam INT,
    grade NUMERIC NULL);


-- ----------------------------------------------------------------
-- 2 Resultado em função da formação dos pais
--escreva a sua solução aqui

DO $$
DECLARE
    cur_aprovados REFCURSOR;
    count_aprovados INT := 0;
BEGIN
    OPEN cur_aprovados FOR 
        SELECT COUNT(*) 
        FROM alunos 
        WHERE grade > 0 
          AND (mother_edu = 6 OR father_edu = 6);    
    FETCH cur_aprovados INTO count_aprovados;
    RAISE NOTICE 'Alunos aprovados com pelo menos um dos pais com PhD: %', count_aprovados;
    CLOSE cur_aprovados;
END;
$$;

-- ----------------------------------------------------------------
-- 3 Resultado em função dos estudos
--escreva a sua solução aqui

DO $$
DECLARE
    cur_estudos REFCURSOR;
    count_estudos INT;
BEGIN
    OPEN cur_estudos FOR 
        SELECT COUNT(*) 
        FROM alunos 
        WHERE grade > 0 
          AND prep_study = 1;       
    FETCH cur_estudos INTO count_estudos;
    IF count_estudos = 0 THEN
        RAISE NOTICE 'Não existem alunos aprovados que estudam sozinhos. Valor: %', -1;
    ELSE
        RAISE NOTICE  'Quantidade de alunos aprovados que estudam sozinhos: %', count_estudos;
    END IF;
    CLOSE cur_estudos;
END;
$$;
-- ----------------------------------------------------------------
-- 4 Salário versus estudos
--escreva a sua solução aqui

DO $$
DECLARE
    cur_salario_estudo CURSOR FOR 
        SELECT COUNT(*)
        FROM alunos
        WHERE salary = 5 AND prep_exam = 2;
    count_preparacao INT;
BEGIN
    OPEN cur_salario_estudo;
    FETCH cur_salario_estudo INTO count_preparacao;
    RAISE NOTICE 'Quantidade de alunos com salário > 410 e preparação regular: %', count_preparacao;
    CLOSE cur_salario_estudo;
END;
$$;

-- ----------------------------------------------------------------
-- 5. Limpeza de valores NULL
--escreva a sua solução aqui

DO $$
DECLARE
    cur_limpeza REFCURSOR;
    tupla RECORD;
BEGIN
    OPEN cur_limpeza FOR 
        SELECT * FROM alunos 
        WHERE 
            activity IS NULL OR
            salary IS NULL OR
            mother_edu IS NULL OR 
            father_edu IS NULL OR
            prep_study IS NULL OR 
            prep_exam IS NULL OR
            grade IS NULL;        
    LOOP
        FETCH cur_limpeza INTO tupla;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Tupla com NULL: %', tupla;
        DELETE FROM alunos WHERE id = tupla.id;
    END LOOP;
    CLOSE cur_limpeza;
    OPEN cur_limpeza SCROLL FOR 
        SELECT * FROM alunos;   
    LOOP
        FETCH BACKWARD FROM cur_limpeza INTO tupla;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Tupla sem NULL: %', tupla;
    END LOOP;
    CLOSE cur_limpeza;
END;
$$;

-- ----------------------------------------------------------------
