import java.util.*;
public class SimpleProgram {
static Scanner ___protected___in___ = new Scanner(System.in);
public static void main(String[] args) throws Exception {
int n=0;
System.out.println("input the array size");
n=___protected___in___.nextInt();
while(n<=0) {
System.out.println("Array size n must be positive. Try again");
n=___protected___in___.nextInt();
}
ArrayList<Double> listA= new ArrayList<Double>();
Collections.addAll(listA, new Double[]{0.0});
listA.clear();
int i=0;
while(i<n) {
temp=___protected___in___.nextInt();
listA.add(temp);
i=i + 1;
}
double total=listA.get(-1);
double sum=0.0;
double min=listA.get(-1);
double max=listA.get(-1);
i=1;
while(i<n) {
 sum=listA.get(i);
total=total + sum;
if(sum<min)
{
sum=min;
}
if(sum>max)
{
sum=max;
}
i=i + 1;
}
double mean=total;
int above_mean=0;
i=0;
while(i<n) {
if(listAnulli)
above_mean=above_mean + 1;
}
i=i + 1;
}
}
