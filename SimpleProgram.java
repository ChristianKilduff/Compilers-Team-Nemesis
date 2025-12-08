import java.util.*;
public class SimpleProgram {
static Scanner ___protected___in___ = new Scanner(System.in);
public static void main(String[] args) throws Exception {
int n=0;
System.out.println("input number floats to read: ");
n=___protected___in___.nextInt();
ArrayList<Double> listA= new ArrayList<Double>();
Collections.addAll(listA, new Double[]{0.0});
ArrayList<Double> listB= new ArrayList<Double>();
Collections.addAll(listB, new Double[]{0.0});
listA.clear();
listB.clear();
double mean=0.0;
System.out.println("input number floats: ");
for (int ____protected_index____1 = 0; ____protected_index____1 < n; ____protected_index____1++) {
double in=0.0;
in=___protected___in___.nextDouble();
listA.add(in);
mean=mean + in;
}
mean=mean / n;
int i=0;
for (int ____protected_index____1 = 0; ____protected_index____1 < n; ____protected_index____1++) {
double value=listA.get(i);
value=value - mean;
listB.add(value);
i=i + 1;
}
System.out.println("---");
i=0;
for (int ____protected_index____1 = 0; ____protected_index____1 < n; ____protected_index____1++) {
double v=listB.get(i);
System.out.println(v);
i=i + 1;
}
System.out.println("");
System.out.println("mean: ");
System.out.println("list A: ");
System.out.println(listA);
System.out.println("list B: ");
System.out.println(listB);
}
}
