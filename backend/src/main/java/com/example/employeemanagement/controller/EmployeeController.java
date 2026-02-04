package com.example.employeemanagement.controller;

import com.example.employeemanagement.exception.ResourceNotFoundException;
import com.example.employeemanagement.model.Employee;
import com.example.employeemanagement.service.EmployeeService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import com.example.employeemanagement.security.JwtTokenUtil;
import java.util.stream.Collectors;

/** This class represents the REST API controller for employees. */
@RestController
@RequestMapping("/api/employees")
@CrossOrigin(origins = "http://localhost:3000")
@Tag(name = "Employees APIs", description = "API Operations related to managing employees")
public class EmployeeController {

  /** The employee service. */
  @Autowired private EmployeeService employeeService;

  /** The JWT token util. */
  @Autowired private JwtTokenUtil jwtTokenUtil;

  /** Fixed JWT token for third party access */
  private static final String THIRD_PARTY_FIXED_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0aGlyZF9wYXJ0eV91c2VyIiwiaWF0IjoxNzI4MDAwMDAwLCJleHAiOjMzMDgwMDAwMDB9.thirdpartyfixedtoken123456789";

  /**
   * Search employees by keyword API (requires JWT token).
   *
   * @param keyword Keyword to search in first name, last name, or email
   * @param token JWT token for third party access
   * @return List of employees matching the keyword
   */
  @Operation(summary = "Search employees by keyword", description = "Search employees by keyword in first name, last name, or email (requires JWT token)")
  @GetMapping("/third-party")
  public List<Employee> searchEmployees(
      @RequestParam(required = false) String keyword,
      @RequestParam String token) {

    // Validate JWT token from parameter
    validateThirdPartyToken(token);

    return employeeService.searchEmployees(keyword);
  }

  /**
   * Get all employees API (requires JWT token for third party).
   *
   * @param token JWT token for third party access
   * @return List of all employees
   */
  @Operation(summary = "Get all employees", description = "Retrieve a list of all employees (requires JWT token)")
  @GetMapping("/third-party/all")
  public List<Employee> getAllEmployees(@RequestParam String token) {
    // Validate JWT token from parameter
    validateThirdPartyToken(token);
    
    return employeeService.getAllEmployees();
  }

  /**
   * Create a new employee API (requires JWT token for third party).
   *
   * @param employee New employee details
   * @param token JWT token for third party access
   * @return New employee record
   */
  @Operation(summary = "Create a new employee", description = "Create a new employee record (requires JWT token)")
  @PostMapping("/third-party")
  public Employee createEmployee(@RequestBody Employee employee, @RequestParam String token) {
    // Validate JWT token from parameter
    validateThirdPartyToken(token);
    
    return employeeService.saveEmployee(employee);
  }

  /**
   * Delete an employee API (requires JWT token for third party).
   *
   * @param id ID of the employee to be deleted
   * @param token JWT token for third party access
   * @return No content
   */
  @Operation(summary = "Delete an employee", description = "Delete an employee record by ID (requires JWT token)")
  @DeleteMapping("/third-party/{id}")
  public ResponseEntity<Void> deleteEmployee(@PathVariable Long id, @RequestParam String token) {
    // Validate JWT token from parameter
    validateThirdPartyToken(token);
    
    // Check if employee exists
    if (!employeeService.getEmployeeById(id).isPresent()) {
      throw new ResourceNotFoundException("Employee not found with id: " + id);
    }
    
    employeeService.deleteEmployee(id);
    return ResponseEntity.noContent().build();
  }

  /**
   * Extract JWT token from Authorization header.
   *
   * @param request HttpServletRequest to extract token
   * @return JWT token string
   */
  private String extractJwtToken(HttpServletRequest request) {
    String bearerToken = request.getHeader("Authorization");
    if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
      return bearerToken.substring(7);
    }
    throw new RuntimeException("JWT token is missing or invalid format");
  }

  /**
   * Validate third party JWT token.
   *
   * @param token JWT token to validate
   */
  private void validateThirdPartyToken(String token) {
    if (!THIRD_PARTY_FIXED_TOKEN.equals(token)) {
      throw new RuntimeException("Invalid JWT token for third party access");
    }
  }

  /**
   * Get employee by ID API.
   *
   * @param id ID of the employee to be retrieved
   * @return Employee with the specified ID
   */
  @Operation(
      summary = "Get employee by ID",
      description = "Retrieve a specific employee by their ID")
  @ApiResponses(
      value = {
        @ApiResponse(responseCode = "200", description = "Employee found"),
        @ApiResponse(responseCode = "404", description = "Employee not found")
      })
  @GetMapping("/{id}")
  public ResponseEntity<Employee> getEmployeeById(@PathVariable Long id) {
    Employee employee =
        employeeService
            .getEmployeeById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + id));
    return ResponseEntity.ok(employee);
  }


  /**
   * Update an existing employee API (requires JWT token for third party).
   *
   * @param id ID of the employee to be updated
   * @param employeeDetails Updated employee details
   * @param token JWT token for third party access
   * @return Updated employee record
   */
  @Operation(
      summary = "Update an existing employee",
      description = "Update an existing employee's details (requires JWT token)")
  @ApiResponses(
      value = {
        @ApiResponse(responseCode = "200", description = "Employee updated"),
        @ApiResponse(responseCode = "404", description = "Employee not found")
      })
  @PutMapping("/third-party/{id}")
  public ResponseEntity<Employee> updateEmployee(
      @PathVariable Long id, @RequestBody Employee employeeDetails, @RequestParam String token) {
    
    // Validate JWT token from parameter
    validateThirdPartyToken(token);
    
    Employee employee =
        employeeService
            .getEmployeeById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + id));

    // Update fields with null checks
    if (employeeDetails.getFirstName() != null) {
      employee.setFirstName(employeeDetails.getFirstName());
    }
    if (employeeDetails.getLastName() != null) {
      employee.setLastName(employeeDetails.getLastName());
    }
    if (employeeDetails.getEmail() != null) {
      employee.setEmail(employeeDetails.getEmail());
    }
    if (employeeDetails.getDepartment() != null) {
      employee.setDepartment(employeeDetails.getDepartment());
    }
    if (employeeDetails.getAge() > 0) {
      employee.setAge(employeeDetails.getAge());
    }

    Employee updatedEmployee = employeeService.saveEmployee(employee);
    return ResponseEntity.ok(updatedEmployee);
  }

  /**
   * Delete an employee API.
   *
   * @param id ID of the employee to be deleted
   * @return No content
   */
  @Operation(summary = "Delete an employee", description = "Delete an employee record by ID")
  @ApiResponses(
      value = {
        @ApiResponse(responseCode = "204", description = "Employee deleted"),
        @ApiResponse(responseCode = "404", description = "Employee not found")
      })
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteEmployee(@PathVariable Long id) {
    Employee employee =
        employeeService
            .getEmployeeById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + id));

    employeeService.deleteEmployee(id);
    return ResponseEntity.noContent().build();
  }
}
