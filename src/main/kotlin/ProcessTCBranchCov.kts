import org.apache.commons.csv.CSVFormat
import java.io.File
import java.io.FileReader
import java.io.FileWriter

val inputFolder = args[0]
val outputFolder = args[1]

combineCoverageFiles(inputFolder, outputFolder)

fun combineCoverageFiles(inputFolder: String, outputFolder: String) {
    println("Starting to combine all coverage files into one file")
    var progress = 0
    CSVFormat.DEFAULT.withHeader(
        "conf-id", "line-numbers", "covered"
    ).print(FileWriter("$outputFolder/combined.csv")).use { printer ->
        File(inputFolder).listFiles()!!.forEach { file ->
            val records = CSVFormat.DEFAULT.parse(FileReader(file))
            records.forEach {
                if (!it[0].startsWith('-')) { // There are branches with line number -1 through -1. Discard them.
                    printer.printRecord(file.nameWithoutExtension, it[0], it[1])
                }
            }

            progress++
            if (progress % 1_000 == 0) {
                println("Processed $progress files...")
            }
        }
    }
    println("Done combining")
}
