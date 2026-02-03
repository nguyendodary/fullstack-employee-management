package com.example.employeemanagement.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/** This class represents the security configuration. */
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  /** The user details service. */
  @Autowired
  private UserDetailsService userDetailsService;

  /**
   * Configure authentication.
   *
   * @param auth The authentication manager builder
   * @throws Exception If an error occurs
   */
  @Override
  protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    auth.userDetailsService(userDetailsService).passwordEncoder(passwordEncoder());
  }

  /**
   * Password encoder.
   *
   * @return The password encoder
   */
  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  /**
   * Authentication manager bean.
   *
   * @return The authentication manager
   * @throws Exception If an error occurs
   */
  @Override
  @Bean
  public AuthenticationManager authenticationManagerBean() throws Exception {
    return super.authenticationManagerBean();
  }

  /**
   * Configure security.
   *
   * @param http The HTTP security
   * @throws Exception If an error occurs
   */
  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http.csrf()
        .disable()
        .authorizeRequests()
        // Third-party employee APIs with JWT token - publicly accessible (token checked in controller)
        .antMatchers("GET", "/api/employees", "/api/employees/search").permitAll()
        // Read-only endpoints - accessible by all authenticated users (ADMIN, USER,
        // VIEWER) - but API key is checked in controller for /api/employees
        .antMatchers("GET", "/api/departments", "/api/departments/**").permitAll()
        // Modify endpoints - only ADMIN and USER roles
        .antMatchers("POST", "/api/employees", "/api/departments").hasAnyRole("ADMIN", "USER")
        .antMatchers("PUT", "/api/employees/*", "/api/departments/*").hasAnyRole("ADMIN", "USER")
        .antMatchers("DELETE", "/api/employees/*", "/api/departments/*").hasAnyRole("ADMIN", "USER")
        // Authentication endpoints - publicly accessible
        .antMatchers("/register", "/authenticate", "/verify-username/**", "/reset-password").permitAll()
        // Swagger/API documentation - publicly accessible
        .antMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-resources/**").permitAll()
        // Home endpoint
        .antMatchers("/", "/api/home").permitAll()
        .anyRequest()
        .permitAll();
  }
}
