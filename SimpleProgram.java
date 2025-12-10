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
double x=0.0;
while(i<n) {
x=___protected___in___.nextInt();
listA.add(x);
i=i + 1;
}
double total=listA.get(0);
double sum=0.0;
double min=listA.get(0);
double max=listA.get(0);
i=1;
while(i<n) {
 sum=listA.get(i);
total=total + sum;
if(sum<min)
{
min=sum;
}
if(sum>max)
{
max=sum;
}
i=i + 1;
}
double mean=total / n;
int above_mean=0;
i=0;
double y=0.0;
while(i<n) {
 y=listA.get(i);
if(y>mean)
{
above_mean=above_mean + 1;
}
i=i + 1;
}
System.out.print("mean = ");
System.out.println(mean);
System.out.print("min = ");
System.out.println(min);
System.out.print("max = ");
System.out.println(max);
System.out.print("above_mean = ");
System.out.println(above_mean);
}
}
