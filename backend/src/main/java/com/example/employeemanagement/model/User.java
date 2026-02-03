package com.example.employeemanagement.model;

import javax.persistence.*;

/** This class represents the user entity. */
@Entity
@Table(name = "users")
public class User {

  /** The user ID. */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  /** The username. */
  @Column(nullable = false, unique = true)
  private String username;

  /** The password. */
  @Column(nullable = false)
  private String password;

  /** The user role. */
  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private UserRole role = UserRole.USER;

  // Getters and Setters

  /**
   * Gets the user ID.
   *
   * @return The user ID
   */
  public Long getId() {
    return id;
  }

  /**
   * Sets the user ID.
   *
   * @param id The user ID
   */
  public void setId(Long id) {
    this.id = id;
  }

  /**
   * Gets the username.
   *
   * @return The username
   */
  public String getUsername() {
    return username;
  }

  /**
   * Sets the username.
   *
   * @param username The username
   */
  public void setUsername(String username) {
    this.username = username;
  }

  /**
   * Gets the password.
   *
   * @return The password
   */
  public String getPassword() {
    return password;
  }

  /**
   * Sets the password.
   *
   * @param password The password
   */
  public void setPassword(String password) {
    this.password = password;
  }

  /**
   * Gets the user role.
   *
   * @return The user role
   */
  public UserRole getRole() {
    return role;
  }

  /**
   * Sets the user role.
   *
   * @param role The user role
   */
  public void setRole(UserRole role) {
    this.role = role;
  }
}
