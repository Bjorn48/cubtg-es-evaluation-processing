import org.apache.commons.csv.CSVFormat
import java.io.FileReader
import java.io.FileWriter
import kotlin.math.roundToInt

val statisticsInputFile = args[0]
val branchCoverageInputFile = args[1]
val statisticsOutputPrefix = args[2]
val executionCountSuiteOutputPrefix = args[3]
val executionCountTestCaseOutputPrefix = args[4]
val categorizedSuiteOutputPrefix = args[5]
val categorizedTestCaseOutputPrefix = args[6]
val diffTestCaseOutputPrefix = args[7]

println("Extracting statistics from $statisticsInputFile")
extractFromStatisticsCsv(statisticsInputFile, statisticsOutputPrefix)

println("Extracting suite sizes from $statisticsInputFile")
val suiteSizes = extractSuiteSizes(statisticsInputFile)

println("Extracting execution count coverage information from $branchCoverageInputFile")
extractFromBranchCoverage(branchCoverageInputFile, suiteSizes, executionCountSuiteOutputPrefix, executionCountTestCaseOutputPrefix)

println("Extracting branch coverage information from $branchCoverageInputFile")
extractCategories(branchCoverageInputFile, categorizedSuiteOutputPrefix, categorizedTestCaseOutputPrefix)

println("Extracting execution count coverage differences from $branchCoverageInputFile")
extractExecutionCountCoverageDifference(branchCoverageInputFile, diffTestCaseOutputPrefix)

println("Finished")

fun extractSuiteSizes(inputFile: String): Map<String, Int> {
    val records = CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(FileReader(inputFile))
    return records.associate { it["configuration_id"] to it["Size"].toInt() }
}

fun extractFromStatisticsCsv(inputFile: String, outputFilePrefix: String) {
    val records = CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(FileReader(inputFile))
    val recordsByConfiguration = records.groupBy {
        val execId = it.get("configuration_id")
        execId.split("-")[1]
    }

    recordsByConfiguration.keys.forEach { confId ->
        val printer = CSVFormat.DEFAULT.withHeader(
            "conf_id", "line_coverage", "branch_coverage", "exception_coverage", "weak_mutation_coverage",
            "method_coverage", "output_coverage", "suite_size", "num_generations"
        ).print(FileWriter(outputFilePrefix + "_" + confId + ".csv"))
        recordsByConfiguration[confId]!!.forEach {
            printer.printRecord(it["configuration_id"], it["LineCoverage"], it["BranchCoverage"], it["ExceptionCoverage"],
                it["WeakMutationScore"], it["MethodCoverage"], it["OutputCoverage"], it["Size"], it["Generations"])
    } }
}

fun extractFromBranchCoverage(inputFile: String, suiteSize: Map<String, Int>, suiteFilePrefix: String, testCaseFilePrefix: String) {
    val records = CSVFormat.DEFAULT.parse(FileReader(inputFile))
    return records.groupBy {
        val execId = it[0]
        execId.split("-")[1]
    }.mapValues { it.value.groupBy { it[0] } }
        .forEach { conf ->
            val suitePrinter = CSVFormat.DEFAULT.print(FileWriter(suiteFilePrefix + "_" + conf.key + ".csv"))
            val testCasePrinter = CSVFormat.DEFAULT.print(FileWriter(testCaseFilePrefix + "_" + conf.key + ".csv"))
            conf.value.filterValues { it.map { it[3].toInt() }.sum() > 0 }.forEach { suitePrinter.printRecord(it.value.map { if (it[2].toInt() > 0) it[3].toInt() else 0 }.sum() /
                    it.value.map { it[3].toInt() }.sum().toDouble()) }
            conf.value.filterValues { it.map { it[3].toInt() }.sum() > 0 }.filterKeys { suiteSize[it]!! > 0 }.forEach { execution -> testCasePrinter.printRecord( execution.value.map { it[2].toInt() * it[3].toInt()}.sum() /
                    execution.value.map { it[3].toInt() }.sum().toDouble()) }
        }
}

fun extractCategories(inputFile: String, suiteFilePrefix: String, testCaseFilePrefix: String) {
    val records = CSVFormat.DEFAULT.parse(FileReader(inputFile))
    return records.groupBy {
        val execId = it[0]
        execId.split("-")[1]
    }.mapValues { it.value.groupBy {it[0]}}
        .mapValues {
            it.value.mapValues { it.value.sortedBy { it[3].toInt() } }
                .filterValues { it.size >= 4 }
            .mapValues { val numberOfBranches = it.value.size
                val cutOffIndexes = listOf(
                    (numberOfBranches * 0.25).roundToInt() - 1,
                    (numberOfBranches * 0.5).roundToInt() - 1,
                    (numberOfBranches * 0.75).roundToInt() - 1
                )
                listOf(it.value.subList(0, cutOffIndexes[0] + 1), it.value.subList(cutOffIndexes[0], cutOffIndexes[1]),
                    it.value.subList(cutOffIndexes[1], cutOffIndexes[2]), it.value.subList(cutOffIndexes[2], it.value.size))
            }}
        .forEach { conf ->
            val suitePrinter = CSVFormat.DEFAULT.print(FileWriter(suiteFilePrefix + "_" + conf.key + ".csv"))
            val testCasePrinter = CSVFormat.DEFAULT.print(FileWriter(testCaseFilePrefix + "_" + conf.key + ".csv"))
            conf.value.map { it.value.map { it.map { if (it[2].toInt() > 0) 1 else 0 }.average() } }
                .forEach { it.forEachIndexed { index, d -> suitePrinter.printRecord(index + 1, d) } }
            conf.value.map { execution -> execution.value.map { it.map { it[2].toInt() }.average() } }
                .forEach { it.forEachIndexed { index, d -> testCasePrinter.printRecord(index + 1, d) } }
        }
}

fun extractExecutionCountCoverageDifference(inputFile: String, testCaseFilePrefix: String) {
    val records = CSVFormat.DEFAULT.parse(FileReader(inputFile))
    val classToConfToCountSum = records.groupBy {
        val execId = it[0]
        execId.split("-")[0]
    }.mapValues { it.value.groupBy {
        val execId = it[0]
        execId.split("-")[1]
    }.mapValues { it.value.map { it[2].toInt() * it[3].toInt() }.sum() }
    }

    val testCasePrinter = CSVFormat.DEFAULT.print(FileWriter("${testCaseFilePrefix}_fit_def_sec_def_to_fit_max_sec_max.csv"))

    classToConfToCountSum.filterValues { it.containsKey("fit_def_sec_def") && it.containsKey("fit_max_sec_max") }
        .mapValues { it.value["fit_max_sec_max"]!! / it.value["fit_def_sec_def"]!!.toDouble() }
        .filterValues { !it.isNaN() }
        .forEach {
            testCasePrinter.printRecord(it.value)
        }
    testCasePrinter.close()
}
