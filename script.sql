--SET SERVEROUTPUT ON;
-- Created on 28-Aug-12 by Lloyd CLEDWYN Lentz
-- Update 12-Dec-16 - LL
declare 
  -- Local variables here
  v_dtype        varchar2(200);
  v_default      varchar2(200);
  v_schema       varchar2(32) := 'ADVCS';
  v_table_name   varchar2(32) := 'GIFT_LOADER_DATA';
  v_string       varchar2(20000);
  
  cursor acur is
  select * 
  from user_tab_columns 
 where table_name = v_table_name
 order by column_id;
 
begin
  -- Test statements here
  
  --select lower(user) into v_username from dual;

  for arow in acur loop
    select decode(arow.data_type,
               'VARCHAR2','string',
               'CHAR', 'string',
               'NUMBER', 'double',
               'DATE' , 'DateTime', 
               arow.data_type) into v_dtype from dual;
               
    select decode(v_dtype, 'string', '""',
                           'double', '0',
                           '""') into v_default from dual;
           
               
    dbms_output.put_line('  public ' || 
       v_dtype  || ' ' ||
      
       arow.column_name ||
       ' = ' || v_default ||
       ';');
  end loop;



dbms_output.put_line('public ' || v_table_name || '(string idNumber)
    { OracleRS.Command cmd = new OracleRS.Command("select * from ' || v_schema || '.' || v_table_name || ' where id_number = :id_number", "' || v_schema || '", CommandType.Text);
      cmd.AddParameterWithValue(":id_number", idNumber);
      foreach (DataRow row in cmd.GetDataTable(false).Rows)
      {');
  for arow in acur loop
    --SPOUSE_ID_NUMBER = aDR["spouse_id_number"].ToString();   
    
    select decode(arow.data_type,
               'VARCHAR2','string',
               'CHAR', 'string',
               'NUMBER', 'double',
               'DATE' , 'DateTime', 
               arow.data_type) into v_dtype from dual;
               
    select decode(v_dtype, 'string', '""',
                           'double', '0',
                           '""') into v_default from dual;
                       
    dbms_output.put_line(
        case when v_dtype in ('string') then  
          arow.column_name || ' = '  || 'row["' || arow.column_name || '"].ToString()' 
        end ||
        case when v_dtype in ('double','DateTime') then 
          v_dtype || '.TryParse( row["' || arow.column_name || '"].ToString(), out ' ||arow.column_name || ')'
        end ||
       ';');
  end loop;

  dbms_output.put_line('}');
  dbms_output.put_line('}');
  dbms_output.put_line(' ');


  dbms_output.put_line('public void Update()
          {');
  v_string := 'string sql = "update ' || v_table_name || ' set ';


  for arow in acur loop
    v_string := v_string  || arow.column_name || ' = :'  || arow.column_name || ', ';
  end loop;
  
  v_string := v_string || ' where ID = :ID"; ';
  dbms_output.put_line(v_string);
  dbms_output.put_line('OracleRS.Command cmd = new OracleRS.Command(sql, "' || v_schema || '", CommandType.Text);');
  for arow in acur loop
    dbms_output.put_line('cmd.AddParameterWithValue(":'  || arow.column_name || '", '  || arow.column_name || ');');
  end loop;
  dbms_output.put_line('cmd.AddParameterWithValue(":ID", ID);');
  dbms_output.put_line('cmd.ExecuteNonQuery();');
  dbms_output.put_line('}');

end;
/
