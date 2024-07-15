using System;
using System.Web;
using System.Security.Principal;
using System.Threading;
using System.Net.Mail;
using System.Data.SqlClient;
using System.Data;
using System.Globalization;
using System.Management;
using System.IO;
using System.Diagnostics;
using System.Net;
using System.Collections;


public class ServerInfo
{

    public static int Main(string[] args)
    {


        //*************************** START OF CONFIGURE ITEMS BY DBA*********************************


        string ApplicationName = "ABC";

        string Environment = "Production";

        string ServerName = "Axxxxxxxxxx";

        string[] Back_Files_Path = { @"H:\Backup\FULL\",@"H:\Backup\LOG\"};

       // string Email_To = @"rajasekharreddyb.dba@gmail.com";

         string Email_To =@"rajasekharreddyb.dba@gmail.com";

        string connectionstring = @"Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=msdb;Data Source=Axxxxxxxxx";

        int Disk_Threshold = 21, Issues_Count = 0;

       
 
        //*************************** END OF CONFIGURE ITEMS BY DBA*********************************

        string DbServers = Dns.GetHostName();
        String TotalBody = String.Empty;
        String MainBody = String.Empty;
        String DbServerBody = String.Empty;

        String DbServerHeader = String.Empty;

        String JobHeader = String.Empty;
        String JobDetail = String.Empty;

        String FilesHeader = String.Empty;
        String FilesDetail = String.Empty;

        String ErrorDetail = String.Empty;
        String ErrorHeader = String.Empty;

        String SQL_ErrorDetail = String.Empty;
        String SQL_ErrorHeader = String.Empty;

        String EvntvwrDetail = String.Empty;
        String EvntvwrHeader = String.Empty;

        String lastrbtDetail = String.Empty;
        String lastrbtHeader = String.Empty;

        String JobdisabledDetail = String.Empty;
        String JobdisabledHeader = String.Empty;

        String BackUpsDetails = String.Empty;
        String BackUpsHeader = String.Empty;

        String EndBody = String.Empty;
  String DBSizesDetails = String.Empty;
        String DBSizesHeader = String.Empty;

        String jobString = String.Empty;

        int TodayDateForJobs = 0;
        int counter = 0;

        char[] DaySymbol = new char[32];

        try
        {
            //---------------------------------------------------------Writing the connection ------------------------------------------------


            SqlConnection conn = new SqlConnection(connectionstring);


            //--------------------------------------------------------Get the Today date in format 20100629------------------------------------

            TodayDateForJobs = int.Parse(DateTime.Today.Year.ToString());
            if (DateTime.Today.Month.ToString().Length == 1)
            {
                if (DateTime.Today.Day.ToString() == "1")
                {
                    TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + "0" + (DateTime.Today.Month - 1).ToString());
                }
                else
                {
                    if (DateTime.Today.Day.ToString() == "1")
                    {
                        TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + "0" + (DateTime.Today.Month - 1).ToString());
                    }
                    else
                    {
                        TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + "0" + DateTime.Today.Month.ToString());
                    }
                }

            }
            else
            {
                TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + DateTime.Today.Month.ToString());
            }
            if (DateTime.Today.Day.ToString().Length == 1)
            {
                if (DateTime.Today.Day.ToString() == "1")
                {
                    TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + (30).ToString());
                }
                else
                {
                    TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + "0" + (DateTime.Today.Day - 1).ToString());
                }
            }
            else
            {
                if ((DateTime.Today.Day - 1).ToString().Length == 1)
                {
                    TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + "0" + (DateTime.Today.Day - 1).ToString());
                }
                else
                {
                    TodayDateForJobs = int.Parse(TodayDateForJobs.ToString() + (DateTime.Today.Day - 1).ToString());
                }
            }



            //--------------------------------------------------------DISK SPACES -------------------------------------------------

	    Console.WriteLine("\nReading disk spaces\n");
            int ServerNumber = 1;
            ConnectionOptions opt = new ConnectionOptions();

            ObjectQuery oQuery = new ObjectQuery("SELECT Size, FreeSpace, Name, FileSystem FROM Win32_LogicalDisk WHERE DriveType = 3");

            DbServerHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=5><h3><font color=#0066FF>  Database Server Disk Drive Details</font></h3></th></tr>";
            DbServerHeader += "<tr><th><font color=#0066FF>Machine</font></th><th><font color=#0066FF>Drive</font></th><th><font color=#0066FF>Size GB</font></th><th><font color=#0066FF>Free Space GB</font></th><th><font color=#0066FF>Free Space %</font></th>";

            string sLine = DbServers;
            while (sLine != null)
            {
                if (ServerNumber <= 1)
                {
                    sLine = DbServers;
                }
                else
                {
                    sLine = null;
                }

                if (sLine != null)
                {
                    ManagementScope scope = new ManagementScope("\\\\" + sLine + "\\root\\cimv2", opt);

                    ManagementObjectSearcher moSearcher = new ManagementObjectSearcher(scope, oQuery);
                    ManagementObjectCollection collection = moSearcher.Get();
                    DbServerBody += "<tr><td><font color=#666633>" + sLine + "</font></td></tr>";
                    foreach (ManagementObject res in collection)
                    {
                        decimal size = Convert.ToDecimal(res["Size"]) / 1024 / 1024 / 1024;
                        decimal freeSpace = Convert.ToDecimal(res["FreeSpace"]) / 1024 / 1024 / 1024;
                        DbServerBody += "<tr>";
                        DbServerBody += "<td></td>";
                        DbServerBody += "<td><font color=#666633>" + res["Name"] + "</font></td>";
                        DbServerBody += "<td><font color=#666633>" + Decimal.Round(size, 2) + " GB </font></td>";
                        DbServerBody += "<td><font color=#666633>" + Decimal.Round(freeSpace, 2) + " GB </font></td>";

                        if ((Decimal.Round(freeSpace / size, 2) * 100) < Disk_Threshold)
                        {
                            Issues_Count++;
                            DbServerBody += "<td><font color=#FF0000>" + Decimal.Round(freeSpace / size, 2) * 100 + "% </font></td>";
                        }
                        else
                        {
                            DbServerBody += "<td><font color=#666633>" + Decimal.Round(freeSpace / size, 2) * 100 + "% </font></td>";
                        }
                        DbServerBody += "</tr>";

                    }
                }
                ServerNumber += 1;

            }
            DbServerBody += "</Table>";

            ServerNumber = 0;
		Console.WriteLine("Disk spaces reading completed\n");



//------------------------------------Databases sizes---------------------------------------------------------------------------------------------

            Console.WriteLine("\nReading Databases sizes\n");
            SqlCommand com_DB = new SqlCommand();
            conn.Open();
            com_DB.Connection = conn;

             jobString = @"
DECLARE @dbs TABLE
( DBname VARCHAR(100),
  Size FLOAT,
  Remarks VARCHAR(1000)
)
INSERT INTO @dbs EXEC sp_databases

DECLARE @FILES TABLE
(
	DatabaseName VARCHAR(100),
	LogicalName VARCHAR(100),
	PhysicalName VARCHAR(1000),
	SizeMB FLOAT
)

INSERT INTO @FILES SELECT DB_NAME(database_id) AS DatabaseName,
Name AS Logical_Name,
Physical_Name, (size*8) SizeMB
FROM sys.master_files
WHERE DB_NAME(database_id) IN (select DBName from @dbs where DBname not in ('master','model','msdb')) 


SELECT f1.DatabaseName, round(SUM(f1.SizeMB)/1024/1024,2) AS 'Total (GB)',(select round(sum(f2.SizeMB)/1024/1024,2) from @Files f2 where f1.DatabaseName = f2.DatabaseName and (f2.PhysicalName like '%.mdf' or f2.PhysicalName like '%ndf')) as 'Data (GB)', (select round(sum(f3.SizeMB)/1024/1024,2) from @Files f3 where f1.DatabaseName =f3.DatabaseName and f3.PhysicalName like '%.ldf') as 'Log (GB)' FROM @FILES f1 GROUP BY f1.DatabaseName
";

            SqlDataAdapter ada_DB = new SqlDataAdapter(jobString, conn);
            DataSet ds_DB = new DataSet();
            ada_DB.Fill(ds_DB, "DBSizes");
            conn.Close();

            DataTable dt_DB = ds_DB.Tables[0];
            foreach (DataRow dRow in dt_DB.Rows)
            {
                DBSizesDetails += "<tr>";
                DBSizesDetails += "<td><font color=#666633>" + dRow["DatabaseName"].ToString() + "</font></td>";
                DBSizesDetails += "<td><font color=#666633>" + dRow["Total (GB)"].ToString() + "</font></td>";
                DBSizesDetails += "<td><font color=#666633>" + dRow["Data (GB)"].ToString() + "</font></td>";
                DBSizesDetails += "<td><font color=#666633>" + dRow["Log (GB)"].ToString() + "</font></td>";
                DBSizesDetails += "</tr>";
            }

            if (ds_DB.Tables[0].Rows.Count == 0)
                DBSizesDetails += "<tr><td colspan=\"2\" align=\"center\"><font color=#666633>No Records Found </font></td></tr>";

            DBSizesDetails += "</Table>";
            DBSizesHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=33><h3><font color=#0066FF>Databases Sizes </font></h3></th></tr>";
            DBSizesHeader += "<tr><th><font color=#0066FF>DatabaseName</font></th><th><font color=#0066FF>Total (GB) </font></th><th><font color=#0066FF>Data (GB) </font></th><th><font color=#0066FF>Log (GB) </font></th></tr>";
            Console.WriteLine("Reading databases sizes completed\n");
            //-------------------------------------------------------------------DATABASE BACK UP FILES ------------------------------------------------
	
		Console.WriteLine("\nReading database back up file details\n");

            int fileCount = 0;
            foreach (string backup_file_path in Back_Files_Path)
            {
		if(Directory.Exists(backup_file_path)) 
		{
                DirectoryInfo di = new DirectoryInfo(backup_file_path);
                FileInfo[] rgFiles = di.GetFiles("*.bak");
                fileCount += rgFiles.Length;
		}
            }

            string[] fileNames = new string[fileCount];
            DateTime[] CreationDate = new DateTime[fileCount];
            long[] fileSize = new long[fileCount];

            int i = 0;
            foreach (string backup_file_path in Back_Files_Path)
            {
		if(Directory.Exists(backup_file_path)) 
		{
                DirectoryInfo di = new DirectoryInfo(backup_file_path);
                FileInfo[] rgFiles = di.GetFiles("*.bak");                
                
                foreach (FileInfo fi in rgFiles)
                {
                    fileNames[i] = fi.FullName;
                    CreationDate[i] = Convert.ToDateTime(fi.LastWriteTime);
                    fileSize[i] = fi.Length;
                    //Console.WriteLine(fileNames[i] + "\t" + CreationDate[i] + "\t" + fileSize[i]);
                    i++;
                }
		}
            }
            for (i = 0; i < fileCount; i++)
                {
                    for (int j = 0; j < fileCount - 1; j++)
                    {
                        if (CreationDate[j]< CreationDate[j+1])
                        {
                            DateTime tempDate = CreationDate[j];
                            CreationDate[j] = CreationDate[j+1];
                            CreationDate[j+1] = tempDate;
                            string tempString = fileNames[j];
                            fileNames[j] = fileNames[j+1];
                            fileNames[j + 1] = tempString;

                            long tempFsize = fileSize[j];
                            fileSize[j] = fileSize[j+1];
                            fileSize[j + 1] = tempFsize;
                        }
                    }
                }



            for (i = 0; i < fileCount; i++)
                {
                    FilesDetail += "<tr>";
                    FilesDetail += "<td><font color=#666633>" + fileNames[i] + "</font></td>";
                    FilesDetail += "<td><font color=#666633>" + CreationDate[i].ToString("dd/MM/yyyy hh:mm:ss tt") + " </font></td>";

                    string bakupsize = "<td><font color=#666633>";
                    long BackUpSize = fileSize[i];
                    if ((BackUpSize / 1024 / 1024 / 1024) > 0)
                    { //If file size is in GBs

                        bakupsize += Math.Round((BackUpSize / 1024.0 / 1024.0 / 1024.0), 2) + " GB </font></td>";
                    }
                    else if ((BackUpSize / 1024 / 1024) > 0)
                    { //If file size is in MBs

                        bakupsize += Math.Round((BackUpSize / 1024.0 / 1024.0), 2) + " MB </font></td>";
                    }
                    else if ((BackUpSize / 1024) > 0)
                    { //If file size is in KBs

                        bakupsize += Math.Round((BackUpSize / 1024.0), 2) + " KB </font></td>";
                    }
                    else if (BackUpSize > 0)
                    { //If file size is in Bytes

                        bakupsize += BackUpSize + " Bytes </font></td>";
                    }
                    FilesDetail += bakupsize + "</font></td>";
                    FilesDetail += "</tr>";
                }
	    if(fileCount < 1)
	    { 
		FilesDetail += "<tr><td colspan=\"3\" align=\"center\">No records found</td></tr>";
	    }

            FilesDetail += "</Table>";
            FilesHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=33><h3><font color=#0066FF>Database Backup files</font></h3></th></tr>";
            FilesHeader += "<tr><th><font color=#0066FF>File Name</font></th><th><font color=#0066FF>Creation Time</font></th><th><font color=#0066FF>Length</font></th></tr>";
            Console.WriteLine("Read Complete for database back up file details\n");



            //------------------------------------------------------------------   JOB STATUS ------------------------------------------------------------------
		Console.WriteLine("\nReading Jobs' status\n");

            SqlCommand comm4 = new SqlCommand();
            conn.Open();
            comm4.Connection = conn;


            jobString = @"select distinct j.job_id as JobID, j.name as Jobname,CONVERT(DATETIME,RTRIM(jh.run_date)) +(jh.run_time * 9 + jh.run_time % 10000 * 6 + jh.run_time % 100 * 10) / 216e4 AS 'Last_run_date', CONVERT(VARCHAR(10),CONVERT(DATETIME,RTRIM(19000101))+(jh.run_duration * 9 + jh.run_duration % 10000 * 6 + jh.run_duration % 100 * 10) / 216e4,108) AS 'Run_Time', jh.run_status  as jobstatus from msdb.dbo.sysjobhistory jh join msdb.dbo.sysjobs j on j.job_id=jh.job_id join msdb.dbo.sysjobschedules js on j.job_id = js.job_id where instance_id=(select MAX(Instance_id) from msdb.dbo.sysjobhistory jh1 where  jh.job_id=jh1.job_id and jh.step_id=jh1.step_id) and jh.step_name='(Job outcome)' and j.enabled =1 Order by Last_run_date DESC";

            SqlDataAdapter adapter4 = new SqlDataAdapter(jobString, conn);
            DataSet ds3 = new DataSet();
            adapter4.Fill(ds3, "Jobs");
            conn.Close();
            Console.WriteLine("Read Complete for jobs status\n");

            if (ds3 != null && ds3.Tables != null && ds3.Tables.Count > 0)
            {
                DataTable dTable = ds3.Tables[0];

                foreach (DataRow dRow in dTable.Rows)
                {
                    if (!(dRow["Jobname"].ToString()).Equals("DBMonitoring_Report"))
                    {
                        JobDetail += "<tr>";
                        JobDetail += "<td><font color=#666633>" + dRow["Jobname"].ToString() + " </font></td>";

                        DateTime JobRunDate = Convert.ToDateTime(dRow["Last_run_date"]);

                        JobDetail += "<td align=center><font color=#666633>" + JobRunDate.ToString("dd/MM/yyyy hh:mm:ss tt") + "  </font></td>";

                        JobDetail += "<td align=center><font color=#666633>" + dRow["Run_Time"].ToString() + " </font></td>";

                        int jobstatus = (int)dRow["jobstatus"];

                        switch (jobstatus)
                        {
                            case 1:
                                JobDetail += "<td><font color=#666633><b>Success</font></td>";
                                break;

                            case 0:
                                JobDetail += "<td><font color=#FF0000><b>Failed </font></td>";
                                Issues_Count++;
                                break;

                            case 2:
                                JobDetail += "<td><font color=#00FF00><b>Retry (step only) </font></td>";
                                break;

                            case 3:
                                JobDetail += "<td><font color=#00FF00><b>Cancelled </font></td>";
                                break;

                            case 4:
                                JobDetail += "<td><font color=#00FF00><b>In-progress message </font></td>";
                                break;

                            case 5:
                                JobDetail += "<td><font color=#00FF00><b>Unknown </font></td>";
                                break;
                        }

                        //-------------Job current status---------------

                        string Job_ID = dRow["JobID"].ToString();

                        string Current_Status = "";
                        SqlCommand Status_Com = new SqlCommand();
                        conn.Open();
                        Status_Com.Connection = conn;
                        SqlDataAdapter Status_Adapter = new SqlDataAdapter("Exec sp_get_composite_job_info '" + Job_ID + "'", conn);
                        DataSet Status_ds = new DataSet();
                        Status_Adapter.Fill(Status_ds, "SQL_Errors");
                        conn.Close();

                        if (Status_ds != null && Status_ds.Tables != null && Status_ds.Tables.Count > 0)
                        {
                            DataTable Status_dTable = Status_ds.Tables[0];
                            DataRow dataRow = Status_dTable.Rows[0];
                            int Current_Status_Code = (int)dataRow["current_execution_status"];

                            switch (Current_Status_Code)
                            {

                                case 0:

                                    Current_Status += "Not idle or suspended";

                                    break;

                                case 1:

                                    Current_Status += "Executing";

                                    break;

                                case 2:

                                    Current_Status += "Waiting For Thread";

                                    break;

                                case 3:

                                    Current_Status += "Between Retries";

                                    break;

                                case 4:

                                    Current_Status += "Idle";

                                    break;

                                case 5:

                                    Current_Status += "Suspended";

                                    break;

                                case 6:

                                    Current_Status += "WaitingForStepToFinish";

                                    break;

                                case 7:

                                    Current_Status += "PerformingCompletionActions";

                                    break;

                            }
                        }

                        JobDetail += "<td align=center><font color=#666633>" + Current_Status + " </font></td>";
                    }

                }
            }

            if (ds3.Tables[0].Rows.Count < 2)
                JobDetail += "<tr><td colspan=\"5\" align = \"center\"><font color=#666633> No Records Found  </font></td></tr>";
            JobDetail += "</Table>";


            JobHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=33><h3><font color=#0066FF> SQL Job Status (Yesterday)</font></h3></th></tr>";
            JobHeader += "<tr><th><font color=#0066FF>&nbsp;&nbsp;&nbsp;Job Name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></th><th><font color=#0066FF>Last_Run_date</font></th><th><font color=#0066FF>Run_Time(HH:MM:SS) </font></th><th><font color=#0066FF>Job Outcome      </font></th><th><font color=#0066FF>Job Current Status                  </font></th></tr>";



            //--------------------------------------------------------- SQL SERVER AGENT  ERROR  LOG DETAILS --------------------------------------------------------------------

            Console.WriteLine("\nRead SQL server agent errort log Details\n");
		ArrayList Agent_errors = new ArrayList();
            SqlCommand comm6 = new SqlCommand();
            conn.Open();
            counter = 0;
            comm6.Connection = conn;
            SqlDataAdapter adapter6 = new SqlDataAdapter("EXEC sp_readerrorlog 0, 2", conn);
            DataSet ds6 = new DataSet();
            adapter6.Fill(ds6, "SQL_Errors");
            conn.Close();

            if (ds6 != null && ds6.Tables != null && ds6.Tables.Count > 0)
            {
                DataTable dTable = ds6.Tables[0];
                foreach (DataRow dRow in dTable.Rows)
                {
                    DateTime dtt = DateTime.Parse(dRow["LogDate"].ToString());
                    if (dtt >= DateTime.Today)
                    {
                        if (dRow["ErrorLevel"].ToString() == "1")
                        {
				counter++;
								int count = 0;
                		foreach (string msg in Agent_errors)
                		{
                    			if (msg.Equals(dRow["Text"].ToString()))
                    			{
                        		count=1;
                        		break;
                    			}
                		}
	        		if(count==0)
                		{
                            		Agent_errors.Add(dRow["Text"].ToString());
                            		SQL_ErrorDetail += "<tr>";
                            		SQL_ErrorDetail += "<td width=\"160\"><font color=#666633>" + dtt.ToString("dd/MM/yyyy hh:mm:ss tt") + "</font></td>";
                            		SQL_ErrorDetail += "<td><font color=#666633>" + dRow["Text"].ToString() + " </font></td>";
                            		SQL_ErrorDetail += "</tr>";
				}	
                        }
                    }

                }
            }


            if (counter == 0)
                SQL_ErrorDetail += "<tr><td colspan=\"2\" align=\"center\"><font color=#666633> No Records Found  </font></td></tr>";

            SQL_ErrorDetail += "</Table>";

            SQL_ErrorHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=33><h3><font color=#0066FF> SQL Agent Error Log Details</font></h3></th></tr>";
            SQL_ErrorHeader += "<tr><th><font color=#0066FF>Log Date</font></th><th><font color=#0066FF>Message</font></th></tr>";
            Console.WriteLine("Read Complete for SQL sERVER Agent Error Log Details\n");




            
            //-------------------------------------------------------ERROR LOG DETAILS  -------------------------------------------------------------


	    Console.WriteLine("\nRead Error Log Details\n");

		ArrayList Error_Msgs = new ArrayList();
	    SqlCommand comm5 = new SqlCommand();
            conn.Open();
            comm5.Connection = conn;
            SqlDataAdapter adapter5 = new SqlDataAdapter("EXEC sp_readerrorlog 0,1", conn);
            DataSet ds5 = new DataSet();
            adapter5.Fill(ds5, "Errors");
            conn.Close();
            DataTable table = ds5.Tables["Errors"];

	    DateTime todayDate = DateTime.Now; //getting today's date
            todayDate -=todayDate.TimeOfDay; //getting today's date with zero hours


            DataRow[] TodayLogEntries;
	    DataRow[] TodayErrorEntries;
            counter = 0;

            // Use the Select method to find all rows matching the filter.

	    TodayLogEntries = table.Select("LogDate > '" + todayDate.ToString("yyyy-MM-dd HH:mm:ss") + "'"); 

	    TodayErrorEntries = table.Select("Text like '%Error:%'");

	    for(int j = 0; j < TodayErrorEntries.Length; j++)
	    {
		DateTime ErrDate = Convert.ToDateTime(TodayErrorEntries[j][0]);

            	for (i = 0; i < TodayLogEntries.Length-1; i++)
            	{
			DateTime LogDate = Convert.ToDateTime(TodayLogEntries[i][0]);

			if(DateTime.Compare(ErrDate, LogDate) == 0)
			{
				int count = 0;
                		foreach (string msg in Error_Msgs)
                		{
                    			if (msg.Equals(TodayLogEntries[i][2].ToString()))
                    			{
                        		count=1;
                        		break;
                    			}
                		}
	        		if(count==0)
                		{
				Error_Msgs.Add(TodayLogEntries[i][2].ToString());
                		ErrorDetail += "<tr>";
                		ErrorDetail += "<td width=\"160\"><font color=#666633>" + LogDate.ToString("dd/MM/yyyy hh:mm:ss tt") + "</font></td>";
                		ErrorDetail += "<td><font color=#666633>" + TodayLogEntries[i][2].ToString() + " </font></td>";
                		ErrorDetail += "</tr>";
				}
                		counter++;
			}

            	}
	    }

            if (counter == 0)
            {
                ErrorDetail += "<tr><td colspan=\"2\" align=\"center\" ><font color=#666633> No Records Found  </font></td></tr>";
            }

            ErrorDetail += "</Table>";

            ErrorHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=33><h3><font color=#0066FF>Error Log Details</font></h3></th></tr>";
            ErrorHeader += "<tr><th><font color=#0066FF>Log Date</font></th><th><font color=#0066FF>Message</font></th></tr>";
            Console.WriteLine("Read Complete for Error Log Details\n");

            conn.Close();



            //---------------------------------------------------  EVENT VIEWER DETAILS ----------------------------------------------------

        


            //-----------------------------------------------------------LAST REBOOT TIME -------------------------------------------------------------

            Console.WriteLine("\nGetting last bootup details details\n");
		string sKey = @"System\CurrentControlSet\Control\Windows";

            Microsoft.Win32.RegistryKey key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(sKey);
            string sValueName = "ShutdownTime";
            object val = key.GetValue(sValueName);
            DateTime output = DateTime.MinValue;
            if (val is byte[] && ((byte[])val).Length == 8)
            {
                byte[] bytes = (byte[])val;
                System.Runtime.InteropServices.ComTypes.FILETIME ft = new System.Runtime.InteropServices.ComTypes.FILETIME();
                int valLow = bytes[0] + 256 * (bytes[1] + 256 * (bytes[2] + 256 * bytes[3]));
                int valTwo = bytes[4] + 256 * (bytes[5] + 256 * (bytes[6] + 256 * bytes[7]));
                ft.dwLowDateTime = valLow;
                ft.dwHighDateTime = valTwo;

                output = DateTime.FromFileTimeUtc((((long)ft.dwHighDateTime) << 32) + ft.dwLowDateTime);
                lastrbtDetail += output.ToString("dd/MM/yyyy hh:mm:ss tt");
            }
            Console.WriteLine("Read Complete for LastBootUpTime Details\n");


            //------------------------------------------------------ JOBS DISABLED /SCHEDULE DISABLED ---------------------------------------------------

		Console.WriteLine("\nGetting disabled/unscheduled jobs list\n");
            SqlCommand comm7 = new SqlCommand();
            conn.Open();
            comm7.Connection = conn;

            jobString = @"select 'Job(s) Disabled ' as Type,convert(varchar(200),name) as Job_Name from msdb.dbo.sysjobs where enabled=0 UNION ALL select Distinct 'Job(s)-Schedule Disabled ' as Type, convert(varchar(200),(J.name +' - '+S.name)) as Job_Name from   msdb.dbo.sysjobschedules js  JOIN msdb.dbo.sysjobs j on j.job_id=js.job_id   JOIN msdb.dbo.sysschedules S on js.schedule_id=S.schedule_id  where S.enabled=0  UNION ALL select 'Job(s) with no schedule  ' as Type,convert(varchar(200),J.name) as Job_Name from   msdb.dbo.sysjobs J LEFT JOIN msdb.dbo.sysjobschedules js   ON J.job_id=js.job_id where js.Schedule_id is null";

            SqlDataAdapter adapter7 = new SqlDataAdapter(jobString, conn);
            DataSet ds7 = new DataSet();
            adapter7.Fill(ds7, "Jobsdisabled");
            conn.Close();

            DataTable dTable1 = ds7.Tables[0];

            foreach (DataRow dRow in dTable1.Rows)
            {
                JobdisabledDetail += "<tr>";
                JobdisabledDetail += "<td><font color=#666633>" + dRow["Type"].ToString() + "</font></td>";
                JobdisabledDetail += "<td><font color=#666633>" + dRow["job_name"].ToString() + "</font></td>";
                JobdisabledDetail += "</tr>";
            }

            if (ds7.Tables[0].Rows.Count == 0)
                JobdisabledDetail += "<tr><td colspan=\"2\" align=\"center\"><font color=#666633>No Records Found </font></td></tr>";

            JobdisabledDetail += "</Table>";
            JobdisabledHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=33><h3><font color=#0066FF>JOBS DISABLED /SCHEDULE DISABLED </font></h3></th></tr>";
            JobdisabledHeader += "<tr><th><font color=#0066FF>Type</font></th><th><font color=#0066FF>Jobs Name</font></th></tr>";
            Console.WriteLine("Read Complete for jobs disabled  status\n");

            //------------------------------------------BackUPTypes & Time ---------------------------------------------------------------------------

Console.WriteLine("\nRead Backup types and time\n");
            SqlCommand comm8 = new SqlCommand();
            conn.Open();
            comm8.Connection = conn;

            jobString = @"SELECT * From (select bs.database_name As DBName, MAX(bs.backup_finish_date)as BackUpDate,bs.type as Type from msdb..backupset bs JOIN sys.databases sdb on 
bs.database_name = sdb.name and bs.type in ('D','L') GROUP BY bs.database_name,bs.type
)DB
PIVOT(MAX(BackUpDate) FOR Type IN([D],[L]))As pvt";
            SqlDataAdapter adapter8 = new SqlDataAdapter(jobString, conn);
            DataSet ds8 = new DataSet();
            adapter8.Fill(ds8, "Backups");
            conn.Close();

            DataTable dTable2 = ds8.Tables[0];

            foreach (DataRow dRow in dTable2.Rows)
            {
                BackUpsDetails += "<tr>";
                BackUpsDetails += "<td><font color=#666633>" + dRow["DBName"].ToString() + "</font></td>";
                if (dRow["D"] == DBNull.Value)
                {
                    BackUpsDetails += "<td><font color=#666633>" + "Not applicable" + "</font></td>";
                }
                else
                {
                    DateTime DataBackup = Convert.ToDateTime(dRow["D"]);
                    BackUpsDetails += "<td><font color=#666633>" + DataBackup.ToString("dd/MM/yyyy hh:mm:ss tt") + "</font></td>";
                }
                if (dRow["L"] == DBNull.Value)
                {
                    BackUpsDetails += "<td><font color=#666633>" + "Not applicable" + "</font></td>";
                }
                else
                {
                    DateTime TranBackup = Convert.ToDateTime(dRow["L"]);
                    BackUpsDetails += "<td><font color=#666633>" + TranBackup.ToString("dd/MM/yyyy hh:mm:ss tt") + "</font></td>";
                }
                BackUpsDetails += "</tr>";
            }

            if (ds8.Tables[0].Rows.Count == 0)
                BackUpsDetails += "<tr><td colspan=\"2\" align=\"center\"><font color=#666633>No Records Found </font></td></tr>";

            BackUpsDetails += "</Table>";
            BackUpsHeader = "<Table border=1 bgcolor=#CCFF99><tr><th colspan=33><h3><font color=#0066FF>Last Backups Information</font></h3></th></tr>";
            BackUpsHeader += "<tr><th><font color=#0066FF>DataBase Name</font></th><th><font color=#0066FF>Last Data Backup Time</font></th><th><font color=#0066FF>Last Transactional Backup Time</font></th></tr>";
            Console.WriteLine("Read Complete Database backup type & time details\n");


            //------------------------------------------------------ASSIGING ALL THE ITEMS TO THE MAIN TABLE-----------------------------------------

            EndBody = "</h1></body></html>";

            String MainTable;
            MainTable = "<table border=0 bgcolor=#FFFFCC>";

            MainTable += "<tr align=center><td align=center colspan=2><h2><font color=#0000FF>" + ApplicationName + " " + Environment + "  Server's Status Report ( " + System.DateTime.Now.ToString("F", CultureInfo.InvariantCulture) + " )</font></h2></td></tr>";

            MainTable += "<tr align=center><td align= colspan=2><h3><font color=\"red\"> Last BootUp Time: " + lastrbtDetail + "</font></h3></td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + DbServerHeader + DbServerBody + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + DBSizesHeader + DBSizesDetails + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + BackUpsHeader + BackUpsDetails + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + FilesHeader + FilesDetail + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + JobdisabledHeader + JobdisabledDetail + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + JobHeader + JobDetail + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + SQL_ErrorHeader + SQL_ErrorDetail + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + ErrorHeader + ErrorDetail + "</td></tr>";

            MainTable += "<tr valign=top><td colspan=2 valign=top width=100%>" + EvntvwrHeader + EvntvwrDetail + "</td></tr>";

            MainTable += "</table>";

            TotalBody = MainBody + MainTable + EndBody;
        }
        catch (Exception ex)
        {
            TotalBody = MainBody + ex.Message + EndBody;
        }

        //************************************************************** SENDING MAIL *************************************************************

        string Date_Time = DateTime.Today.ToString("d", CultureInfo.CreateSpecificCulture("en-NZ"));
        string Notification_Msg = "";
        using (MailMessage mail = new MailMessage())
        {
            mail.To.Add(Email_To);
            mail.From = new MailAddress("SQL Server DBA <RajasekharReddyb.dba@gmail.com>", @"SQL Server DBA ");
            mail.IsBodyHtml = true;

            if (Issues_Count > 0)
            {
                Notification_Msg += Issues_Count + " Issue(s) found";
            }
            else
            {
                Notification_Msg += "No Issues";
            }

            mail.Subject = ApplicationName + "  >>  " + Environment + "  >>  " + ServerName + " >> 178.26.34.34 >> Server Report on " + Date_Time + " ----- " + Notification_Msg;
            mail.Body = TotalBody;
            SmtpClient SmtpMail = new SmtpClient("SGA0EXC.ktc.gm.com");
            
            SmtpMail.Send(mail);
Console.WriteLine("\n\nMail Send sucessfully");
        }
        return 0;
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         