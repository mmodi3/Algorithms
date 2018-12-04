CXX      = g++ #References which compiler
CXX_FILE = $(wildcard *.cpp) #finds file that ends in .cpp 
TARGET   = $(patsubst %.cpp,%,$(CXX_FILE)) #removes .cpp extension from file, as it is being treated as an executable
CXXFLAGS = -g  -std=c++11 -Wall -Werror -pedantic-errors -fmessage-length=0 

#-g puts in debugging mode, use -o2 or -o3 for more optimized runtimes 
#-std=c++11 sets version to C++ version 11
#-Wall makes it so all warnings are displayed (read as W all)
#-Werror (Every warning is treated as an error)
#pedantic-errors makes diagnositc warning messages also error and fail compilation
#-fmessage-length=0 makes all warnings appear in one line  


all: #Dependencies would go here
	$(CXX) $(CXXFLAGS) $(CXX_FILE) -o $(TARGET) #states the format for calling the file in terminal
	#When you type make it automatically places that

clean:
	rm -f $(TARGET) $(TARGET).exe  
