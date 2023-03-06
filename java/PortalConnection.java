
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "postgres";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
      String reply = "";

      try (PreparedStatement ps = conn.prepareStatement(
              "INSERT INTO Registrations (student, course) VALUES (?, ?)")
      ) {
          ps.setString(1, student);
          ps.setString(2, courseCode);
          ps.execute();
          reply = "{\"success\":true}\n";
      } catch (SQLException e) {
        reply = String.format("{\"success\":false, \"error\":\"%s\"}", getError(e));
      }

      return reply;
        // Here's a bit of useful code, use it or delete it
      // } catch (SQLException e) {
      //    return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      // }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
      String reply = "";
      try (PreparedStatement ps = conn.prepareStatement(
              "DELETE FROM Registrations WHERE student=? AND course=?");) {
        ps.setString(1, student);
        ps.setString(2, courseCode);
        int rowsUpdated = ps.executeUpdate();
        if (rowsUpdated > 0)
          reply = "{\"success\":true}\n";
        else
          reply = "{\"success\":false, \"error\":\"0 rows affected\"}";
      } catch (SQLException e) {
        reply = String.format("{\"success\":false, \"error\":\"%s\"}", getError(e));
      }

      return reply;
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
            "SELECT jsonb_build_object('student',idnr, 'name',name, 'login',login, 'program',program, 'branch',branch, 'finished',json_agg(jsonb_build_object('code',FinishedCourses.course,'credits',FinishedCourses.credits , 'grade',FinishedCourses.grade)), 'registered',json_agg(jsonb_build_object('code',Registrations.course, 'status',Registrations.status)) , 'seminarCourses',seminarCourses, 'mathCredits',mathCredits, 'researchCredits',researchCredits, 'totalCredits',totalCredits, 'canGraduate',qualified) AS jsondata FROM BasicInformation JOIN PathToGraduation ON BasicInformation.idnr = PathToGraduation.student JOIN FinishedCourses on BasicInformation.idnr = FinishedCourses.student JOIN Registrations ON BasicInformation.idnr = Registrations.student WHERE idnr=? GROUP BY(Basicinformation.idnr, Basicinformation.name, BasicInformation.login, basicinformation.program, basicinformation.branch, pathtograduation.seminarcourses, pathtograduation.mathcredits, pathtograduation.researchcredits, pathtograduation.totalcredits, pathtograduation.qualified)");)
        {
            st.setString(1, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}