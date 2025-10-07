#include <bits/stdc++.h>
using namespace std; typedef unsigned long long ull;

mt19937 mt( (ull)( time(0) ) );
int Rand  ( int l, int r ) { return uniform_int_distribution<int>(l,r)(mt); }

const string opt_array[] = { "insert", "delete", "update", "select_key", "select_easy", "select_hard" };

struct Movies {
    int id;
    string title, country;
    int release_year, duration;

    Movies () {}
    Movies ( int a, string b, string c, int d, int e ) : id(a), title(b), country(c), release_year(d), duration(e) {}
};

vector <Movies> vec, res;

const size_t BUFFER_SIZE = 1 << 18;

char buffer[BUFFER_SIZE];
size_t buffer_ptr = 0, buffer_size = 0;

bool fast_getline ( std::string & str, char delimiter ) {
    str.clear();

    while ( true ) {
        if( buffer_ptr >= buffer_size ) {
            buffer_size = fread(buffer, 1, BUFFER_SIZE, stdin);
            buffer_ptr = 0;
            if( buffer_size == 0 ) return !str.empty();
        }

        size_t i = buffer_ptr;
        while( i < buffer_size && buffer[i] != delimiter ) ++i;

        str.append(buffer + buffer_ptr, i - buffer_ptr), buffer_ptr = i + 1;

        if (i < buffer_size) return true;
    }
}

void Solve ( int n, string opt ) {
    ifstream input( "movies.txt"  );
    std::cin.rdbuf( input.rdbuf() );

    fseek( stdin, 0, SEEK_SET ), buffer_ptr = buffer_size = 0;

    vec.clear();
    res.clear();

    clock_t start = clock();

    if( n >= 1e6 ) {
        for( int i = 1; i <= n; ++i ) {
            Movies movies;
            string str;
            fast_getline( str, '\t' ), movies.id           = stoi( str );
            fast_getline( str, '\t' ), movies.title        = str;
            fast_getline( str, '\t' ), movies.country      = str;
            fast_getline( str, '\t' ), movies.release_year = stoi( str );
            fast_getline( str, '\n' ), movies.duration     = stoi( str );
            vec.push_back( movies );
        }
    } else {
        for( int i = 1; i <= n; ++i ) {
            Movies movies;
            string str;
            getline( cin, str, '\t' ), movies.id           = stoi( str );
            getline( cin, str, '\t' ), movies.title        = str;
            getline( cin, str, '\t' ), movies.country      = str;
            getline( cin, str, '\t' ), movies.release_year = stoi( str );
            getline( cin, str, '\n' ), movies.duration     = stoi( str );
            vec.push_back( movies );
        }
    }

    if( opt == "insert" ) {
        vec.push_back( Movies( Rand( n + 1, 1e9 ), "Liu Lang Di Qiu 2", "China", 2024, 180 ) );
    }
    if( opt == "delete" ) {
        vec.erase( vec.begin() + Rand( 0, n - 1 ) );
    }
    if( opt == "update" ) {
        for( auto & it : vec ) it.release_year += 1;
    }
    if( opt == "select_key"  ) {
        int x = Rand( 1, n );
        for( const auto & it : vec ) if( it.id == x ) { res.push_back( it ); break; }
    }
    if( opt == "select_easy" ) {
        for( const auto & it : vec ) if( 1991 <= it.release_year && it.release_year <= 2000 ) res.push_back( it );
    }
    if( opt == "select_hard" ) {
        for( const auto & it : vec ) if( ( it.duration ^ 180 ) % 5 == 0 ) res.push_back( it );
    }

    if( opt[0] != 's' )
        cerr << log10(n) << " " << opt << " : " << (int)ceil( 1e3 * ( clock() - start ) / CLOCKS_PER_SEC ) << " ms\n";

    ofstream outfile("movies_out.txt");

    for( const auto & it : res ) 
        outfile << it.id << "\t" << it.title << "\t" << it.country << "\t" << it.release_year << "\t" << it.duration << "\n";

    outfile.flush();
    outfile.close();

    if( opt[0] == 's' )
        cerr << log10(n) << " " << opt << " : " << (int)ceil( 1e3 * ( clock() - start ) / CLOCKS_PER_SEC ) << " ms\n";
}

signed main ( ) {
    freopen( "movies.txt", "r", stdin );
    ios::sync_with_stdio(false), cin.tie(0), cout.tie(0);

    for( int n : { 1e2, 1e4, 1e6, 1e8 } ) {
        for( int i = 0; i < 6; ++i ) {
            Solve( n, opt_array[i] );
            Solve( n, opt_array[i] );
            Solve( n, opt_array[i] );
            Solve( n, opt_array[i] );
            Solve( n, opt_array[i] );
            cerr << endl;
        }
    }

    return 0;
}