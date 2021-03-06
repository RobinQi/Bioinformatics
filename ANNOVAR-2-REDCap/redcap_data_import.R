#!/usr/bin/Rscript
# USAGE: redcap_data_import.R /path/to/OUTPUT_GENE_TABLE.csv <service URL> <API_TOKEN>
# args[6]: /path/to/OUTPUT_GENE_TABLE.csv
# args[7]: <service URL>
# args[8]: <API_TOKEN>

# This script will import the annotation data to REDCap

# install.packages("httr") # might need this if httr is not already installed
library(httr)

# get commands passed to the script
args <- commandArgs()
Gene_Table_filepath<-args[6]
Service_URL<-args[7]
API_Token<-args[8]

print("R: input is: ")
print(args[6])


#******************************
#*** Import Records
Gene_Table<-read.csv(file = Gene_Table_filepath)

name_string <- paste(colnames(Gene_Table),collapse=',')

data_string <- capture.output(write.table(Gene_Table, sep=',', 
                                          col.names=FALSE, row.names=FALSE))
x_string <- paste(c(name_string, data_string, ''), collapse='\n')

POST(url=Service_URL,
     body=list(token=API_Token,  # required
               content='record',   # required
               format='csv',       # required
               type='flat',        # required
               type='normal',              # required: 'normal' or 'overwrite'
               data=x_string,      # required
               
               returnContent='ids', # 'ids','count', or 'nothing'
               returnFormat ='csv' # 'csv', 'json', or 'xml'
     ))


