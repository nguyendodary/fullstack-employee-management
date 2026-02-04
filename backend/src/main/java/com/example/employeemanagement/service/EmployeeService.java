package com.example.employeemanagement.service;

import com.example.employeemanagement.model.Employee;
import com.example.employeemanagement.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/** This class represents the service for employees. */
@Service
public class EmployeeService {

  /** The employee repository. */
  @Autowired private EmployeeRepository employeeRepository;

  /**
   * Get all employees.
   *
   * @return List of all employees
   */
  public List<Employee> getAllEmployees() {
    return employeeRepository.findAllWithDepartments();
  }

  /**
   * Get employee by ID.
   *
   * @param id ID of the employee to be retrieved
   * @return Employee with the specified ID
   */
  public Optional<Employee> getEmployeeById(Long id) {
    return employeeRepository.findById(id);
  }

  /**
   * Save an employee.
   *
   * @param employee Employee to be saved
   * @return Saved employee
   */
  public Employee saveEmployee(Employee employee) {
    return employeeRepository.save(employee);
  }

  /**
   * Search employees by keyword.
   *
   * @param keyword Keyword to search (null or empty returns all)
   * @return List of employees matching the keyword
   */
  public List<Employee> searchEmployees(String keyword) {
    List<Employee> allEmployees = employeeRepository.findAllWithDepartments();
    
    // If no keyword provided, return all employees
    if (keyword == null || keyword.trim().isEmpty()) {
      return allEmployees;
    }
    
    String lowerKeyword = keyword.toLowerCase();

    return allEmployees.stream()
        .filter(emp -> 
            (emp.getFirstName() != null && emp.getFirstName().toLowerCase().contains(lowerKeyword)) ||
            (emp.getLastName() != null && emp.getLastName().toLowerCase().contains(lowerKeyword)) ||
            (emp.getEmail() != null && emp.getEmail().toLowerCase().contains(lowerKeyword)))
        .collect(Collectors.toList());
  }

  /**
   * Delete an employee.
   *
   * @param id ID of the employee to be updated
   */
  public void deleteEmployee(Long id) {
    employeeRepository.deleteById(id);
  }
}
