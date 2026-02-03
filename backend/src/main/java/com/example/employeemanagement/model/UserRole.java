package com.example.employeemanagement.model;

/** Enum representing user roles in the system. */
public enum UserRole {
    /** Administrator role - full access */
    ADMIN("ROLE_ADMIN"),

    /** User role - can create, read, update, delete */
    USER("ROLE_USER"),

    /** Viewer role - read-only access */
    VIEWER("ROLE_VIEWER");

    private final String authority;

    UserRole(String authority) {
        this.authority = authority;
    }

    public String getAuthority() {
        return authority;
    }
}
