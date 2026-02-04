import subprocess
import sys
import socket

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def run_command(cmd):
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def main():
    print("=== Setting up third-party database access ===")
    
    # Step 1: Create user
    print("\n1. Creating read-only user...")
    success, stdout, stderr = run_command(
        'docker exec employee-management-fullstack-app-master-mysql-1 mysql -u root -ppassword employee_management < backend/create_user_simple.sql'
    )
    
    if success:
        print("✓ User created successfully!")
    else:
        print("✗ Failed to create user:")
        print(stderr)
        return
    
    # Step 2: Get IP address
    ip_address = get_local_ip()
    print(f"\n2. Your IP address: {ip_address}")
    
    # Step 3: Display connection info
    print("\n3. Connection information for third party:")
    print("=" * 50)
    print(f"Host: {ip_address}")
    print("Port: 3306")
    print("Database: employee_management")
    print("Username: third_party_viewer")
    print("Password: ReadOnlyAccess2024!")
    print("=" * 50)
    
    # Step 4: Test connection
    print("\n4. Testing connection...")
    success, stdout, stderr = run_command('python backend/test_readonly_user.py')
    
    if success:
        print("✓ Connection test completed!")
    else:
        print("✗ Connection test failed:")
        print(stderr)
    
    # Step 5: Firewall reminder
    print("\n5. IMPORTANT: Make sure port 3306 is open in your firewall!")
    print("   Run this command in PowerShell as Administrator:")
    print(f'   netsh advfirewall firewall add rule name="MySQL" dir=in action=allow protocol=TCP localport=3306')
    
    print("\n=== Setup completed! ===")
    print("Send the connection information above to the third party.")
    print("Also send them the THIRD_PARTY_DB_ACCESS_GUIDE.md file.")

if __name__ == "__main__":
    main()
