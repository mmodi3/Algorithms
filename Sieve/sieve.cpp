/*******************************************************************************
 * Name        : sieve.cpp
 * Author      : Mitra Modi
 * Date        : 9.16.18
 * Description : Sieve of Eratosthenes
 * Pledge      : I pledge my honor that I have abided by the stevens honor system
 ******************************************************************************/
#include <cmath>
#include <iomanip>
#include <iostream>
#include <sstream>

using namespace std;
/*
 * Class that is used to create the primesieve
 */
class PrimesSieve {
public:
    PrimesSieve(int limit) : is_prime_{new bool[limit + 1]}, limit_{limit} {
    	for(int i = 2; i <= limit; i++){
    		is_prime_[i] = true;
    	}
        sieve();
        num_primes_ = count_num_primes();
    }

    /*
     * Deletes is_prime_
     */
    ~PrimesSieve() {
        delete [] is_prime_;
    }

    /*
     * Getter method for num_primes_
     */
    inline int num_primes() const {
        return num_primes_;
    }

    /*
     * Method to print the primes, right alligned and spaced to match the largest prime number in the list
     * Works via consistent checks on the current length of the line, with a constant max_prime_width present to ensure that the spacing remains consistent
     */
    void display_primes() const {
    		cout << "Number of primes found: " << num_primes() << endl;
    	    cout << "Primes up to " << limit_ << ":" << endl;
    		const int max_prime_width = num_digits(max_prime_);
    		int length = 0;
        for(int i = 2; i <= limit_; i++){
        	if(max_prime_width*num_primes() <= 80){
        		if(is_prime_[i] && length == 0){
        			cout << i;
        			length++;
        		} else if (is_prime_[i]) {
        			cout << ' ' << i;
        		}
        	}
        	else if(is_prime_[i]){
        		if(length + max_prime_width + 1 > 80){
        			length = 0;
        			cout << endl;
        			cout << setw(max_prime_width) << i;
        			length += max_prime_width;
        		}
        		else if(length + max_prime_width + 1 == 80){
        			cout << setw(max_prime_width + 1) << i << endl;
        			length = 0;
        		}
        		else if(is_prime_[i] && length == 0){
        			cout << setw(max_prime_width) << i;
        			length += max_prime_width;
        		}
        		else if(is_prime_[i]){
        			cout << setw(max_prime_width + 1) << i;
        			length += max_prime_width + 1;
        		}
        }
        }
    }



private:
    bool * const is_prime_;
    const int limit_;
    int num_primes_, max_prime_;

    /*
     * Private method that counts the number of primes, and also sets the max_prime
     * Max prime is set via constantly setting the prime values to max prime, so it sets the value of max_prime to the largest
     */
    int count_num_primes(){
    		int count = 0;
        for(int i = 2; i <= limit_; i++){
        		if(is_prime_[i]){
        			count++;
        			max_prime_ = i;
        		}
        }
    		return count;
    }

    	/*
    	 * Counts digits by incrementing the count as it divides the number by 10
    	 */
    int num_digits(int num) const {
        int count = 0;
        while(num > 0){
        		num /= 10;
        		count++;
        }
        return count;
    }

    /*
     * Implementation of the sieve in code
     */
    void sieve() {
    		int i = 2;
    		while(i <= sqrt(limit_)){
    			if(is_prime_[i]){
    				int j = pow(i,2);
                	while(j <= limit_){
                		is_prime_[j] = false;
                		j += i;
                	}
    			}
    			i++;
    		}
    }
};


int main() {
	cout << "**************************** " <<  "Sieve of Eratosthenes" <<
	            " ****************************" << endl;
	cout << "Search for primes up to: ";
	string limit_str;
	cin >> limit_str;
	int limit;
	// Use stringstream for conversion. Don't forget to #include <sstream>
	istringstream iss(limit_str);
	// Check for error.
	if ( !(iss >> limit) ) {
	    cerr << "Error: Input is not an integer." << endl;
	    return 1;
	}
	if (limit < 2) {
	    cerr << "Error: Input must be an integer >= 2." << endl;
	    return 1;
	}
	cout << endl;
    PrimesSieve(limit).display_primes();
    return 0;
}


