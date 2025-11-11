<%-- 
    Document   : list_students
    Created on : Nov 5, 2025, 2:06:14 PM
    Author     : Admin
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }

        .search input{
            width: 30%;
            margin-bottom:15px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }

        /* Pagination */
        .pagination {
            margin-top: 20px;
            text-align: center;
        }
        .pagination a, .pagination strong {
            display: inline-block;
            margin: 0 5px;
            padding: 8px 12px;
            text-decoration: none;
            border: 1px solid #007bff;
            border-radius: 4px;
            color: #007bff;
            background: white;
        }
        .pagination strong {
            background-color: #007bff;
            color: white;
        }
        .pagination a:hover {
            background-color: #007bff;
            color: white;
        }
        
        .table-responsive {
            overflow-x: auto;
        }

        @media (max-width: 768px) {
            table {
                font-size: 12px;
            }
            th, td {
                padding: 5px;
            }
        }
    </style>
</head>
<body>
    <h1>📚 Student Management System</h1>
    
    <% if (request.getParameter("message") != null) { %>
        <div class="message success">
            <%= request.getParameter("message") %>
        </div>
    <% } %>
    
    <% if (request.getParameter("error") != null) { %>
        <div class="message error">
            <%= request.getParameter("error") %>
        </div>
    <% } %>
    
    <script>
        setTimeout(function() {
        var messages = document.querySelectorAll('.message');
        messages.forEach(function(msg) {
            msg.style.display = 'none';
            });
        }, 3000);
    </script>
    
    <form class="search" action="list_students.jsp" method="GET">
        <input type="text" name="keyword" placeholder="Search by name, code, or major..." 
               value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
        <button class="btn" type="submit">Search</button>
        <a class="btn" href="list_students.jsp">Clear</a>
    </form>

    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
 
    <div class="table-responsive">    
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Student Code</th>
                <th>Full Name</th>
                <th>Email</th>
                <th>Major</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int totalRecords = 0;
    int totalPages = 0;
    int currentPage = 1;
    int recordsPerPage = 10;
    int offset = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "22042005Lducmanh."
        );

        // Get pagination info
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        }
        offset = (currentPage - 1) * recordsPerPage;

        String keyword = request.getParameter("keyword");
        String sql;
        String countSql;
        
        if (keyword != null && !keyword.isEmpty()) {
            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?";
            countSql = "SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ?";
            pstmt = conn.prepareStatement(countSql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            pstmt.setString(3, "%" + keyword + "%");
        } else {
            sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
            countSql = "SELECT COUNT(*) FROM students";
            pstmt = conn.prepareStatement(countSql);
        }

        // Count total records
        ResultSet countRs = pstmt.executeQuery();
        if (countRs.next()) totalRecords = countRs.getInt(1);
        countRs.close();
        pstmt.close();

        totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

        // Query for current page
        if (keyword != null && !keyword.isEmpty()) {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            pstmt.setString(3, "%" + keyword + "%");
            pstmt.setInt(4, recordsPerPage);
            pstmt.setInt(5, offset);
        } else {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, recordsPerPage);
            pstmt.setInt(2, offset);
        }

        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            int id = rs.getInt("id");
            String studentCode = rs.getString("student_code");
            String fullName = rs.getString("full_name");
            String email = rs.getString("email");
            String major = rs.getString("major");
            Timestamp createdAt = rs.getTimestamp("created_at");
%>
            <tr>
                <td><%= id %></td>
                <td><%= studentCode %></td>
                <td><%= fullName %></td>
                <td><%= email != null ? email : "N/A" %></td>
                <td><%= major != null ? major : "N/A" %></td>
                <td><%= createdAt %></td>
                <td>
                    <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
                    <a href="delete_student.jsp?id=<%= id %>" 
                       class="action-link delete-link"
                       onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                </td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
    </table>
    </div>

    <!-- Pagination -->
    <div class="pagination">
        <% if (currentPage > 1) { %>
            <a href="list_students.jsp?page=<%= currentPage - 1 %><%= (request.getParameter("keyword") != null && !request.getParameter("keyword").isEmpty()) ? "&keyword=" + request.getParameter("keyword") : "" %>">Previous</a>
        <% } %>

        <% for (int i = 1; i <= totalPages; i++) { %>
            <% if (i == currentPage) { %>
                <strong><%= i %></strong>
            <% } else { %>
                <a href="list_students.jsp?page=<%= i %><%= (request.getParameter("keyword") != null && !request.getParameter("keyword").isEmpty()) ? "&keyword=" + request.getParameter("keyword") : "" %>"><%= i %></a>
            <% } %>
        <% } %>

        <% if (currentPage < totalPages) { %>
            <a href="list_students.jsp?page=<%= currentPage + 1 %><%= (request.getParameter("keyword") != null && !request.getParameter("keyword").isEmpty()) ? "&keyword=" + request.getParameter("keyword") : "" %>">Next</a>
        <% } %>
    </div>

</body>
</html>
