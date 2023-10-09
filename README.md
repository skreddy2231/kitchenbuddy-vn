# kitchenbuddy-vn
# foodtest
Current framework is called Robot Framework, which is platform-independent, Although the core framework is implemented using python.
- The "Browser" library from Playwright is part of the Playwright framework
- To run web application(Web URL), used 'Browser' library
- to run api tests(POST call), used 'requestslibrary' 

RPA Framework is a collection of open-source libraries and tools for Robotic Process Automation (RPA), and it is designed to be used with both Robot Framework and Python. The goal is to offer well-documented and actively maintained core libraries for Software Robot Developers. The project is: 100% open-source.

**Prerequisite**
1. Install Node.js and NPM
     https://nodejs.org/en/download/
      
3. Install python 
   Python 3.11.5  [PIP will install along with python install]

4. pip install robotframework
5. pip install robotframework-browser
6. rfbrowser init
7. pip install robotframework-requests
8. IDE tool: Visual studio code
     - Go to extensions
       - search for 'robocorp'
       - install "Robot Framework Language Server"
       - reload vscode IDE.
       - run .robot file (robot -d .\results\ BROWSER:chrome .\MenuCart\KitchenBuddy.robot)

### quick check versions ###
--------------------
- node --version (v18.13.0)
- python --version
- pip --version
- robot --version
- python.exe -m pip install --upgrade pip
- pip install -U robotframework-browser
- rfbrowser clean-node
