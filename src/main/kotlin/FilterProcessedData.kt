import java.io.FileReader
import java.io.PrintStream

fun main(args: Array<String>) {
    print("Filtering...")

    val filterClasses = FileReader(args[1]).readLines()

    FileReader(args[0]).use { reader ->
        PrintStream(args[2]).use { writer ->
            reader.forEachLine { line ->
                if (filterClasses.any { line.contains("$it,") })
                    writer.println(line)
            }
        }
    }
    println("Done")
}
