#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <iomanip>
#include <fstream>
#include <string>
#include <vector>
#include <math.h>
#include <iterator>
#include <map>
#include <limits>

typedef std::numeric_limits< double > dbl;

using namespace std;

#define  SIZE_LINE  5000


  struct  Data{
  long int start;
  long int end;
  string region;
  string type;
  };
  




int main( int argc, char *argv[])
{

//====================== INPUT GFF FILES   ================== //

 FILE    *fin;
 
 if (argc<2) {
     printf("\nUsa:\n> GRADO_PA  File_IN.GFF\n");
     exit(0);
     }

 if ( (fin=fopen(argv[1], "r"))==NULL) {
     printf ("\n Problems with %s ??.\n", argv[1]);
     fflush(stdin); getchar(); exit(0);
     }


//=================== READ GFF or GFF3 FILES   ==================== //



 
 char *linea;
 linea = (char *) calloc (SIZE_LINE, sizeof(char));
 if (linea == NULL)    exit(EXIT_FAILURE);

 string word;
 string type;
 long int start,end;
 
 Data aux;
 vector<Data> exons;


 while (!feof(fin))
 { 
      fgets(linea, SIZE_LINE, fin);
      //---> skipping comment lines
      if (linea[0]!='#')
      { 
          stringstream str(linea);
          int column=1;
          while(getline(str, word, '\t'))
          {
                if(column==1)
                {
                   aux.region=word;
                }
                if(column==3)
                {
                   aux.type=word;
                }
                if(column==4)
                {
                   aux.start=stoi(word);
                }
                if(column==5)
                {
                   aux.end=stoi(word);
                }             
          column++;
          }
      }
      if(aux.type=="exon")
      {
          exons.push_back(aux);
      }          			  
 }



  for(int i=0;i<exons.size();i++)
  {
      //cout<<exons[i].region<<"     "<<exons[i].start<<"   "<<exons[i].end<<endl;
  }


    // Mapa de región a vector de Data (exones)
    map<string, vector<Data>> regiones;

    for (size_t i = 0; i < exons.size(); i++) {
        string key = exons[i].region;
        regiones[key].push_back(exons[i]);
    }
    

    // 2. Número de claves (regiones) diferentes
    size_t n_regiones = regiones.size();
    //cout << "Número de regiones únicas: " << n_regiones << "\n";


    // 3. Crear vector que permite indexar regiones numéricamente
    vector<pair<string, vector<Data>>> regiones_numerico(regiones.begin(), regiones.end());

    int num_regions=regiones_numerico.size();
    

    for(int i=0;i < regiones_numerico.size(); i++)
    {
        long int val_min=10000000000;
        vector<Data>& exons_region = regiones_numerico[i].second;
        for(int j=0;j<exons_region.size();j++)
        {
            if(val_min>exons_region[j].start){val_min=exons_region[j].start;}
            //cout<<i<<"     "<<exons_region[j].start<<" "<<exons_region[j].end<<endl;
        }
        for(int j=0;j<exons_region.size();j++)
        {
            exons_region[j].start=exons_region[j].start-val_min;
            exons_region[j].end=exons_region[j].end-val_min;
        }

    }
    
    
    
    long double sum=0;
    long double projected=0;

    for(int i=0;i < regiones_numerico.size(); i++)
    {
        long int val_max=0;
        vector<Data>& exons_region = regiones_numerico[i].second;
        for(int j=0;j<exons_region.size();j++)
        {
            if(val_max<exons_region[j].end){val_max=exons_region[j].end;}
        }
        
        vector<int> dna(val_max);  
        
        for(int k=0;k<val_max;k++){dna[k]=0;}

        for(int j=0;j<exons_region.size();j++)
        {
            for(int k=exons_region[j].start;k<exons_region[j].end;k++)
            {
                dna[k]++;
            }
        }
        
        for(int j=0;j<val_max;j++)
        {
            sum=sum+dna[j];
            if(dna[j]>0)
            {
               projected++;
            }
        }
        
    }
    
    long double ASR=sum/projected;
    
    cout<<ASR<<endl;
    
    

}



