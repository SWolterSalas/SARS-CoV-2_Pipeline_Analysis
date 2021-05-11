

library(ggplot2)
library(tidyverse)
library(scales)


lineages = read.csv("All_Lineages.csv",na.strings = "")
lineages
lineages_PANGOLIN = lineages

lineages_PANGOLIN$date=as.Date(lineages_PANGOLIN$date)

PANGOLIN <- ggplot(lineages_PANGOLIN, aes(x = date))

PANGOLIN + geom_density() +
  geom_vline(aes(xintercept = mean(date)), 
             linetype = "dashed", size = 0.6)+
  geom_density(aes(fill = pangolin_lineage), alpha = 0.4,position = "fill")


PANGOLIN_SELECTION = lineages
PANGOLIN_SELECTION$date=as.Date(PANGOLIN_SELECTION$date)

PANGOLIN_SELECTION_2 = PANGOLIN_SELECTION %>%
  mutate(Lineages = case_when(
    startsWith(pangolin_lineage, "B.1.526") ~ "B.1.526",
    startsWith(pangolin_lineage, "B.1.1.7") ~ "B.1.1.7",
    startsWith(pangolin_lineage, "B.1.427+B.1.429") ~ "B.1.427+B.1.429",
    startsWith(pangolin_lineage, "B.1.427") ~ "B.1.427",
    startsWith(pangolin_lineage, "B.1.429") ~ "B.1.429",
    #startsWith(pangolin_lineage, "B.1.1.348") ~ "B.1.1.348",
    #startsWith(pangolin_lineage, "B.1.110") ~ "B.1.110",
    startsWith(pangolin_lineage, "B.1.1.1") ~ "B.1.1.1",
    startsWith(pangolin_lineage, "B.1.1") ~ "B.1.1",
    startsWith(pangolin_lineage, "B.1") ~ "B.1",
    startsWith(pangolin_lineage, "B") ~ "Other",
    startsWith(pangolin_lineage, "A") ~ "Other",
    startsWith(pangolin_lineage, "C.37") ~ "C.37",
    startsWith(pangolin_lineage, "C") ~ "Other",
    startsWith(pangolin_lineage, "P.1") ~ "P.1",
    startsWith(pangolin_lineage, "P.2") ~ "P.2",
    startsWith(pangolin_lineage, "N") ~ "N"
  ))

PANGOLIN3 <- ggplot(PANGOLIN_SELECTION_2, aes(x = date))

PANGOLIN3 + 
  geom_density(aes(fill = Lineages), alpha = 0.8,position = "fill") +
  scale_x_date(date_breaks = "months" , date_labels = "%b")+
  scale_fill_manual(values = c("#FC9B70", "#FCB932", "#BEC567", "#90CF7F", "#85C957", "#82DECF", 
                             "#80CBDA", "#7CB9FC", "#C1C1C1", "#D69EBF", "#EDB1DC", "#D7716F"))


